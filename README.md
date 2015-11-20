# git_credit
Determine relative historical contributions by author in a git repo.

1. rename the ruby file 'credit'
2. put in /usr/bin or somewhere else in your PATH
3. invoke the command passing a dir or file that is in a git repo

Example:
```
> cd /Users/jesse/animoto/applications/client_service
> credit app/controllers/zendesk_auth_controller.rb
```
The output will be something like:
```
44% Justin Camerer
43% Chris Korhonen
6% Jordan Brough
5% Travis
1% dannymc129
```
Now you know to ask if you have a question about zendesk in client service
