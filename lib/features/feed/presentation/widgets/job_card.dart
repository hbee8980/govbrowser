import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../data/models/job_item.dart';
import '../../../../core/theme/app_theme.dart';

/// Card widget for displaying a job listing
class JobCard extends StatelessWidget {
  final JobItem job;
  final VoidCallback? onApply;
  final VoidCallback? onViewNotification;
  final VoidCallback? onBookmark;

  const JobCard({
    super.key,
    required this.job,
    this.onApply,
    this.onViewNotification,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onViewNotification,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (job.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          job.category!,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        job.category!,
                        style: TextStyle(
                          color: _getCategoryColor(job.category!),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Bookmark button
                  IconButton(
                    icon: Icon(
                      job.isBookmarked
                          ? PhosphorIcons.bookmarkSimple(
                            PhosphorIconsStyle.fill,
                          )
                          : PhosphorIcons.bookmarkSimple(),
                      size: 20,
                      color:
                          job.isBookmarked
                              ? AppTheme.primaryColor
                              : Colors.grey,
                    ),
                    onPressed: onBookmark,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                job.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Organization
              Row(
                children: [
                  Icon(
                    PhosphorIcons.buildings(),
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.organization,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  // Deadline
                  _InfoChip(
                    icon: PhosphorIcons.calendar(),
                    label: job.formattedDeadline,
                    color:
                        job.isUrgent
                            ? AppTheme.urgentColor
                            : job.isExpired
                            ? Colors.grey
                            : AppTheme.successColor,
                  ),
                  const SizedBox(width: 12),
                  // Vacancies
                  if (job.vacancies != null)
                    _InfoChip(
                      icon: PhosphorIcons.users(),
                      label: '${job.vacancies} posts',
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),

              // Eligibility
              if (job.eligibility != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.graduationCap(),
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.eligibility!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // View Notification
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewNotification,
                      icon: Icon(PhosphorIcons.fileText(), size: 18),
                      label: const Text('Notification'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply Now
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: job.isExpired ? null : onApply,
                      icon: Icon(PhosphorIcons.paperPlaneTilt(), size: 18),
                      label: Text(job.isExpired ? 'Expired' : 'Apply Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            job.isExpired ? Colors.grey : AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),

              // Affiliate Section - Study Material
              const SizedBox(height: 12),
              const Divider(),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  leading: Icon(PhosphorIcons.books(), color: Colors.orange),
                  title: const Text(
                    'Study Material & Mocks',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    _AffiliateLink(
                      icon: PhosphorIcons.amazonLogo(),
                      text: 'Best Books for ${job.category ?? "Exam"}',
                      subtext: 'Get 20% off on Amazon',
                      onTap: () {
                        // TODO: Open Amazon Affiliate Link
                      },
                    ),
                    const SizedBox(height: 8),
                    _AffiliateLink(
                      icon: PhosphorIcons.pencilCircle(),
                      text: 'Take Mock Test',
                      subtext: 'Powered by Testbook',
                      onTap: () {
                        // TODO: Open Test Series Link
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'SSC':
        return Colors.blue;
      case 'UPSC':
        return Colors.purple;
      case 'BANKING':
        return Colors.green;
      case 'RAILWAY':
        return Colors.orange;
      case 'STATE PSC':
        return Colors.teal;
      case 'INSURANCE':
        return Colors.indigo;
      default:
        return AppTheme.primaryColor;
    }
  }
}

class _AffiliateLink extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final VoidCallback onTap;

  const _AffiliateLink({
    required this.icon,
    required this.text,
    required this.subtext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtext,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

/// Small info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
