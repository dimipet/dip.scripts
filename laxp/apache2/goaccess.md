Use this for your specific log
```
$ sudo goaccess /var/log/apache2/access.log --log-format='%v %h %^[%d:%t %^] \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" ' --date-format=%d/%b/%Y --time-format=%T
```

# Apache2 log configuration
```
$ most /etc/apache2/apache2.conf
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%v %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
```

# Combined log 
logs are output to `/var/log/apache2/access.log`. combined logs produces something like this
```
thess.ncec.gr 188.117.225.19 - e2oc_operator [29/Feb/2024:12:28:33 +0200] "GET /nextcloud/ocs/v2.php/apps/user_status/api/v1/user_status?format=json HTTP/1.1" 200 5313 "-" "Mozilla/5.0 (Windows) mirall/3.9.3stable-Win64 (build 20230818) (Nextcloud, windows-10.0.19045 ClientArchitecture: x86_64 OsArchitecture: x86_64)"
```
# mod_log_config variables
check this page mod_log_config variables <https://httpd.apache.org/docs/2.4/mod/mod_log_config.html>
```
%v	The canonical ServerName of the server serving the request.

%h	Remote hostname. Will log the IP address if HostnameLookups is set to Off, which is the default. 
	If it logs the hostname for only a few hosts, you probably have access control directives mentioning them by name. 
	See the Require host documentation.

%l	Remote logname (from identd, if supplied). This will return a dash unless mod_ident is present and IdentityCheck is set On.

%u	Remote user if the request was authenticated. May be bogus if return status (%s) is 401 (unauthorized).

%t	Time the request was received, in the format [18/Sep/2011:19:18:28 -0400]. The last number indicates the timezone offset from GMT

\"%r\"	First line of request. quoted

%>s	Status. For requests that have been internally redirected, this is the status of the original request. Use %>s for the final status. 

%O	Bytes sent, including headers. May be zero in rare cases such as when a request is aborted before a response is sent. 
	You need to enable mod_logio to use this.

\"%{Referer}i\" 	
	optional HTTP header field that identifies the address of the web page from which a user has navigated to the current page.

\"%{User-Agent}i\""
```

