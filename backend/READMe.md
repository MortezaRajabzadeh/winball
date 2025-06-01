# Winball backend created with golang.

### buy ubuntu server 20.04 or later

### then install go version go1.23.0 or later version on your

on the server you must do these things : 1. enable firewall 2. install golang 3. install nginx 4. install mysql 5. add password to your mysql server and add database in database folder of your project into your server DB. 6. add database password and database name to the database.go file. 7. go to configs file and add your CoinMarketCapApi 8. you can also change the value of WITHDRAWABLE\*LESS_THAN => it means withdrawable if be less than this number then the withdeaw will get created. 9. WIN_RATE means the possibility that user can win for example if it says 10 then the possibility that user wins will be 10 percent.
after changing and debugging all of the values you must run the go project with these commands `go mod tidy` this command will get all of the project dependency and then after it run `go run .` and if in terminal programm print: "connected to database" without any errors then all of the things are setted up correctly!
after that run `go build .` this command will create a runnable file .
you must create a service into your os to run this runnalbe file automatically.
then config your nginx server for this
first create these files into your nginx with these contents:
`back.winball.xyz panel.winball.xyz  winball.xyz`
each file content: back.winball.xyz=>

```
server{
listen 80;
listen [::]:80;
listen 443 ssl http2;
listen [::]:443 ssl http2;
ssl_certificate /etc/ssl/cert.pem;
ssl_certificate_key /etc/ssl/key.pem;
ssl_client_certificate /etc/ssl/cloudflare.crt;
ssl_verify_client on;
server_name back.winball.xyz www.back.winball.xyz;
add_header Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval' *.youtube.com maps.gstatic.com _.googleapis.com _.google-analytics.com cdnjs.cloudflare.com assets.zendesk.com connect.facebook.net; frame-src 'self' \_.youtube.com assets.zendesk.com \*.facebook.com s-static.ak.facebook.com tautt.zendesk.com; object-src 'self'";

        location /{
                proxy_pass http://localhost:8080;
         if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';

        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
     }
     if ($request_method = 'POST') {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,Authorization,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
     }
     if ($request_method = 'GET') {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,Authorization,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
     }

}
location /ws {
proxy_pass http://localhost:8080/ws;

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
        proxy_read_timeout 10d;
        proxy_send_timeout 10d;

##enable cors
if ($request_method = 'OPTIONS') {
add_header 'Access-Control-Allow-Origin' '\*';
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';

        add_header 'Access-Control-Allow-Headers' 'DNT,Authorization,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';

        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
     }
     if ($request*method = 'POST') {

add_header 'Access-Control-Allow-Origin' '*' always;
add*header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
add_header 'Access-Control-Allow-Headers' 'DNT,Authorization,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
}
if ($request_method = 'GET') {
add_header 'Access-Control-Allow-Origin' '\*' always;
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
add_header 'Access-Control-Allow-Headers' 'DNT,Authorization,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
}
}
}

```

then you must create these files:

```
ssl_certificate /etc/ssl/cert.pem;
ssl_certificate_key /etc/ssl/key.pem;
ssl_client_certificate /etc/ssl/cloudflare.crt;

```

the content of winball.xyz file :

```
server{
listen 80;
listen [::]:80;
listen 443 ssl http2;
listen [::]:443 ssl http2;
ssl_certificate /etc/ssl/cert.pem;
ssl_certificate_key /etc/ssl/key.pem;
ssl_verify_client on;
ssl_client_certificate /etc/ssl/cloudflare.crt;
server_name winball.xyz www.winball.xyz;
root /var/www/winball.xyz;
location /{
index index.html index.htm;

        }

}

```

and content of the panel.winball.xyz

```

server{
listen 80;
listen [::]:80;
listen 443 ssl http2;
listen [::]:443 ssl http2;
ssl_certificate /etc/ssl/cert.pem;
ssl_certificate_key /etc/ssl/key.pem;
ssl_verify_client on;
ssl_client_certificate /etc/ssl/cloudflare.crt;
server_name panel.winball.xyz www.panel.winball.xyz;
root /var/www/panel.winball.xyz;
location /{
index index.html index.htm;

        }

}

```

by setting these files for your nginx then link them into the sites-enabled directory and the create these directories with content of winball game and panel of the winball game in path : /var/www/winball.xyz & /var/www/panel.winball.xyz
after of setting all of that you must run `nginx -t` and status must be successfull then after of that successfull message run `nginx -s reload`
with all of that project must be accessfull at these addresses : back.winball.xyz , panel.winball.xyz and winball.xyz:=>is telegram bot address and it will be run only in telegram bot mini app .
