"""
Advanced GovBrowser Job Scraper
Scrapes FULL job details from Sarkari Result including:
- Important Dates (Apply Begin, Last Date, Exam Date, Admit Card)
- Application Fees (Category-wise)
- Age Limit (Min/Max with relaxation)
- Vacancy Details (Post-wise, Area-wise)
- Eligibility Requirements

Runs via GitHub Actions daily (FREE)
"""

import json
import re
import os
from datetime import datetime
from urllib.request import urlopen, Request
from urllib.parse import urljoin, quote
import time


def clean_url(url, base_url="https://www.sarkariresult.com"):
    """Clean and validate URL"""
    if not url:
        return None
    
    # Remove spaces and invalid characters
    url = url.strip()
    if ' ' in url:
        url = url.split()[0]  # Take first part before space
    
    # Skip PDFs and external files
    if url.endswith('.pdf') or url.endswith('.jpg') or url.endswith('.png'):
        return None
    
    # Build full URL
    if not url.startswith('http'):
        url = urljoin(base_url, url)
    
    # Validate URL format
    if not url.startswith('http'):
        return None
    
    return url


def fetch_page(url, retries=2):
    """Fetch HTML content from URL with retries"""
    if not url:
        return ""
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
    }
    
    for attempt in range(retries):
        try:
            req = Request(url, headers=headers)
            with urlopen(req, timeout=15) as response:
                return response.read().decode('utf-8', errors='ignore')
        except Exception as e:
            if attempt == retries - 1:
                print(f"Failed: {str(e)[:50]}")
            time.sleep(1)
    
    return ""


def get_job_links(html, base_url="https://www.sarkariresult.com"):
    """Extract job detail page links from main page"""
    links = []
    
    # Pattern to find job links - more specific
    pattern = r'<a[^>]*href=["\']([^"\']+)["\'][^>]*>([^<]+)</a>'
    matches = re.findall(pattern, html, re.IGNORECASE)
    
    seen = set()
    skip_titles = ['latest jobs', 'admit card', 'answer key', 'result', 'syllabus', 
                   'home', 'contact', 'about', 'more', 'click here', 'read more']
    
    for url, title in matches:
        title = title.strip()
        
        # Skip too short or generic titles
        if len(title) < 15:
            continue
        
        # Skip navigation links
        if title.lower() in skip_titles:
            continue
            
        # Skip non-job URLs
        skip_urls = ['facebook', 'twitter', 'youtube', 'instagram', 'whatsapp', 
                     'privacy', 'disclaimer', 'contact', 'about', '#']
        if any(word in url.lower() for word in skip_urls):
            continue
        
        # Must contain job-related words
        job_words = ['recruitment', 'vacancy', 'admit', 'result', 'online', 'form', 
                     'notification', 'exam', 'post', '2024', '2025', '2026']
        if not any(word in title.lower() for word in job_words):
            continue
        
        # Clean URL
        clean = clean_url(url, base_url)
        if not clean:
            continue
        
        if clean not in seen:
            seen.add(clean)
            links.append({'url': clean, 'title': title})
    
    return links[:25]  # Limit to 25 jobs


def extract_dates(html):
    """Extract important dates from job page"""
    dates = {}
    
    # More specific date patterns - look for dates in DD/MM/YYYY format
    date_patterns = [
        (r'Application\s*Begin[^0-9]*(\d{2}/\d{2}/\d{4})', 'application_begin'),
        (r'Last\s*Date[^0-9]*Apply[^0-9]*(\d{2}/\d{2}/\d{4})', 'last_date'),
        (r'Last\s*Date[^0-9]*(\d{2}/\d{2}/\d{4})', 'last_date'),
        (r'Exam\s*Date[^0-9]*(\d{2}/\d{2}/\d{4})', 'exam_date'),
        (r'Admit\s*Card[^0-9]*(\d{2}/\d{2}/\d{4})', 'admit_card'),
    ]
    
    for pattern, key in date_patterns:
        if key not in dates:
            match = re.search(pattern, html, re.IGNORECASE)
            if match:
                dates[key] = match.group(1)
    
    return dates


def extract_fees(html):
    """Extract application fees from job page - improved to avoid wrong numbers"""
    fees = {}
    
    # Look for fee section specifically
    fee_section = re.search(r'Application\s*Fee.*?(?=Age|Eligibility|Important|How)', html, re.IGNORECASE | re.DOTALL)
    if fee_section:
        section = fee_section.group(0)
    else:
        section = html
    
    # Fee patterns - must end with /- to be valid fee
    fee_patterns = [
        (r'General[^0-9]{0,20}(\d{2,4})/-', 'general'),
        (r'OBC[^0-9]{0,20}(\d{2,4})/-', 'obc'),
        (r'SC\s*/?\s*ST[^0-9]{0,20}(\d{2,4})/-', 'sc_st'),
        (r'EWS[^0-9]{0,20}(\d{2,4})/-', 'ews'),
        (r'Female[^0-9]{0,20}(\d{2,4})/-', 'female'),
    ]
    
    for pattern, key in fee_patterns:
        match = re.search(pattern, section, re.IGNORECASE)
        if match:
            fee = int(match.group(1))
            # Validate fee is reasonable (between 0 and 5000)
            if 0 <= fee <= 5000:
                fees[key] = fee
    
    return fees


def extract_age_limit(html):
    """Extract age limit from job page"""
    age = {}
    
    # Look for age section
    age_section = re.search(r'Age\s*Limit.*?(?=Application|Eligibility|How|Important)', html, re.IGNORECASE | re.DOTALL)
    section = age_section.group(0) if age_section else html
    
    min_match = re.search(r'Minimum\s*Age[^0-9]*(\d{2})\s*Years?', section, re.IGNORECASE)
    max_match = re.search(r'Maximum\s*Age[^0-9]*(\d{2})\s*Years?', section, re.IGNORECASE)
    
    if min_match:
        age['min'] = int(min_match.group(1))
    if max_match:
        age['max'] = int(max_match.group(1))
    
    # Age as on date
    as_on = re.search(r'as\s*on\s*(\d{2}/\d{2}/\d{4})', section, re.IGNORECASE)
    if as_on:
        age['as_on'] = as_on.group(1)
    
    return age


def extract_vacancies(html):
    """Extract vacancy count from job page"""
    vacancies = {}
    
    # Pattern for total vacancies - more specific
    patterns = [
        r'Total\s*:?\s*(\d{1,6})\s*Post',
        r'Vacancy[^0-9]*Total[^0-9]*(\d{1,6})',
        r'(\d{1,6})\s*(?:Posts?|Vacancies)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, html, re.IGNORECASE)
        if match:
            num = int(match.group(1))
            if 1 <= num <= 500000:
                vacancies['total'] = num
                break
    
    return vacancies


def extract_eligibility(html):
    """Extract eligibility from job page"""
    eligibility = []
    
    patterns = [
        r'(10th\s*(?:Class\s*)?Pass(?:ed)?[^.]{0,50})',
        r'(12th\s*(?:Class\s*)?Pass(?:ed)?[^.]{0,50})',
        r'(Graduate(?:ion)?\s*(?:in\s*Any\s*)?[^.]{0,50})',
        r'(B\.?Tech[^.]{0,30})',
        r'(ITI[^.]{0,30})',
        r'(Diploma[^.]{0,30})',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, html, re.IGNORECASE)
        if match:
            text = match.group(1).strip()
            if len(text) > 5:
                eligibility.append(text[:80])
    
    return list(set(eligibility))[:2]


def get_job_type(title):
    """Determine job type from title"""
    title_lower = title.lower()
    if 'admit' in title_lower:
        return 'Admit Card'
    elif 'result' in title_lower:
        return 'Result'
    elif 'answer' in title_lower:
        return 'Answer Key'
    return 'Recruitment'


def get_category(title):
    """Determine job category from title"""
    title_lower = title.lower()
    
    categories = [
        (['ssc', 'staff selection'], 'SSC'),
        (['upsc', 'ias', 'ips', 'nda', 'cds'], 'UPSC'),
        (['ibps', 'rbi', 'sbi', 'bank', 'nabard', 'lic', 'insurance'], 'Banking'),
        (['railway', 'rrb', 'ntpc'], 'Railway'),
        (['army', 'navy', 'air force', 'defence', 'bsf', 'crpf', 'cisf', 'agniveer'], 'Defence'),
        (['rssb', 'rpsc', 'rajasthan'], 'Rajasthan'),
        (['uppsc', 'upsssc', 'uttar pradesh'], 'UP'),
        (['bpsc', 'bihar'], 'Bihar'),
        (['mppsc', 'mpesb', 'madhya pradesh'], 'MP'),
        (['police', 'constable'], 'Police'),
    ]
    
    for keywords, category in categories:
        if any(kw in title_lower for kw in keywords):
            return category
    
    return 'Central Govt'


def scrape_job_detail(url, title):
    """Scrape full details from a job page"""
    print(f"  {title[:45]}...", end=" ")
    
    html = fetch_page(url)
    if not html:
        print("❌")
        return None
    
    job = {
        'title': title,
        'url': url,
        'type': get_job_type(title),
        'category': get_category(title),
        'dates': extract_dates(html),
        'fees': extract_fees(html),
        'age_limit': extract_age_limit(html),
        'vacancies': extract_vacancies(html),
        'eligibility': extract_eligibility(html),
        'scraped_at': datetime.now().isoformat(),
    }
    
    print("✅")
    return job


def main():
    """Main function"""
    print("=" * 50)
    print("GovBrowser Advanced Job Scraper v2")
    print("=" * 50)
    
    base_url = "https://www.sarkariresult.com/"
    print(f"\n📡 Fetching: {base_url}")
    
    html = fetch_page(base_url)
    if not html:
        print("❌ Failed to fetch main page")
        return
    
    job_links = get_job_links(html, base_url)
    print(f"📋 Found {len(job_links)} job links\n")
    
    jobs = []
    for i, link in enumerate(job_links[:15]):  # Limit to 15 for speed
        print(f"[{i+1:2d}/{min(len(job_links), 15)}]", end="")
        job = scrape_job_detail(link['url'], link['title'])
        if job:
            jobs.append(job)
        time.sleep(0.5)
    
    print(f"\n✅ Successfully scraped {len(jobs)} jobs")
    
    # Save output
    output = {
        'last_updated': datetime.now().isoformat(),
        'total_jobs': len(jobs),
        'source': 'sarkariresult.com',
        'jobs': jobs,
    }
    
    output_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(output_dir, 'jobs.json')
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Saved to: {output_file}")
    
    # Show sample
    if jobs:
        print("\n📋 Sample:")
        j = jobs[0]
        print(f"   Title: {j['title'][:50]}")
        print(f"   Category: {j['category']}")
        print(f"   Dates: {j.get('dates', {})}")
        print(f"   Fees: {j.get('fees', {})}")
        print(f"   Vacancies: {j.get('vacancies', {})}")


if __name__ == '__main__':
    main()
