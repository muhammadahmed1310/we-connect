# For app
alias cda='cd /var/www/we-connect/current'
alias ber='RAILS_ENV=staging bundle exec rake'

alias nginxRestart='sudo systemctl restart nginx.service'
alias nginxConfig='sudo nginx -T'
alias nginxLogs='sudo tail -f /var/log/nginx/error.log'
alias nginxAccessLogs='sudo tail -f /var/log/nginx/access.log'
alias nginxStatus='systemctl status nginx.service'
alias nginxEdit='sudo nano /etc/nginx/sites-enabled/lvn2.conf'

alias pumaRestart='systemctl --user reload lvn2_puma_{ENV}'
alias pumaStatus='systemctl --user status lvn2_puma_{ENV}'
alias pumaLogs='journalctl --user-unit lvn2_puma_{ENV} -f'
alias appLogs='tail -f /var/www/lvn2/shared/log/{ENV}.log'
alias cronLogs='tail -f /var/www/lvn2/shared/log/cron.log'