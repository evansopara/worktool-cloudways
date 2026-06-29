<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><?php echo e($notifTitle); ?></title>
  <style>
    body { margin: 0; padding: 0; background: #f4f4f5; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
    .wrapper { max-width: 560px; margin: 40px auto; background: #ffffff; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
    .header { background: #1d4ed8; padding: 28px 32px; }
    .header-title { color: #ffffff; font-size: 18px; font-weight: 700; margin: 0; letter-spacing: -0.3px; }
    .header-sub { color: #bfdbfe; font-size: 13px; margin: 4px 0 0; }
    .body { padding: 32px; }
    .icon-wrap { width: 48px; height: 48px; background: #eff6ff; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; }
    .icon-wrap svg { width: 22px; height: 22px; color: #1d4ed8; }
    .title { font-size: 17px; font-weight: 700; color: #111827; margin: 0 0 10px; }
    .message { font-size: 15px; color: #4b5563; line-height: 1.6; margin: 0 0 28px; }
    .btn { display: inline-block; background: #1d4ed8; color: #ffffff; text-decoration: none; font-size: 14px; font-weight: 600; padding: 11px 24px; border-radius: 7px; }
    .divider { border: none; border-top: 1px solid #f3f4f6; margin: 28px 0 20px; }
    .footer { padding: 0 32px 28px; }
    .footer p { font-size: 12px; color: #9ca3af; margin: 0; line-height: 1.5; }
    .app-name { font-weight: 700; color: #6b7280; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="header">
      <p class="header-title"><?php echo e(config('app.name')); ?></p>
      <p class="header-sub">You have a new notification</p>
    </div>
    <div class="body">
      <div class="icon-wrap">
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
      </div>
      <p class="title"><?php echo e($notifTitle); ?></p>
      <p class="message"><?php echo e($notifMessage); ?></p>
      <?php if($actionUrl): ?>
        <a href="<?php echo e($actionUrl); ?>" class="btn"><?php echo e($actionLabel); ?></a>
      <?php endif; ?>
    </div>
    <hr class="divider" />
    <div class="footer">
      <p>You are receiving this email because an action was taken on your <span class="app-name"><?php echo e(config('app.name')); ?></span> account. If this wasn't you, please ignore this email.</p>
    </div>
  </div>
</body>
</html>
<?php /**PATH C:\Users\HP\Documents\GitHub\worktool-cloudways\resources\views/emails/notification.blade.php ENDPATH**/ ?>