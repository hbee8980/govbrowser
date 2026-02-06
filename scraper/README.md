# GovBrowser Job Scraper

Automatically scrapes government job listings from Sarkari Result and updates daily via GitHub Actions.

## How It Works

1. **GitHub Actions** runs `scraper.py` every day at 6:00 AM IST
2. Scraper fetches latest jobs from Sarkari Result
3. Saves to `jobs.json` 
4. Your Flutter app reads this file for job listings

## Setup Instructions

### 1. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit with scraper"
git remote add origin https://github.com/hbee8980/govbrowser.git
git push -u origin main
```

### 2. Enable GitHub Actions

1. Go to your repo on GitHub
2. Click **Actions** tab
3. Enable workflows if prompted

### 3. Test Manually

1. Go to **Actions** → **Scrape Jobs Daily**
2. Click **Run workflow** → **Run workflow**
3. Wait for it to complete
4. Check `scraper/jobs.json` for updated data

## Files

| File | Purpose |
|------|---------|
| `scraper/scraper.py` | Python script to scrape jobs |
| `scraper/requirements.txt` | Python dependencies |
| `scraper/jobs.json` | Output file with job listings |
| `.github/workflows/scrape-jobs.yml` | GitHub Actions workflow |

## Schedule

- Runs automatically at **6:00 AM IST** daily
- You can also trigger manually from Actions tab
- Uses **free** GitHub Actions minutes (2000/month)

## Customization

Edit `scraper.py` to:
- Add more job websites
- Change scraping patterns
- Add more job categories
