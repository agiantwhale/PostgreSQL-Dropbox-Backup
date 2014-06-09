PostgreSQL-Dropbox-Backup
=========================

This bash script allows you to back up your PostgreSQL database to a Dropbox account.
Run it as a cronjob or whatever.
Relies on [Dropbox-Uploader](https://github.com/andreafabrizi/Dropbox-Uploader).

### Requirements
You need cURL (Because of Dropbox-Uploader).

### Environment Variables
You need to set DATABASE_URL to the URL Schema explained over [here](https://github.com/kennethreitz/dj-database-url).
```
export DATABASE_URL=postgresql://user:pass@ip:port/database
```

### Instructions
Clone the repo, assign execution permission to backup.sh (chmod +x backup.sh) and run it for the first time to set up Dropbox & test create your first back up.
Then install it as a cronjob or whatever.
