# simple query
$ dig dimipet.com

# dig from specific nameserver
$ dig @1.1.1.1 dimipet.com

# find a domain's authoritative nameservers
$ dig +short ns dimipet.com
dns1.some-dns-provider.gr.
dns3.some-dns-provider.gr.

# find specific record types
$ dig @8.8.8.8 dimipet.com MX

# find all record types
$ dig @8.8.8.8 dimipet.com ANY

# use ipv6 nameserver to query ipv6
$ dig -6 @2001:4860:4860::8888 dimipet.com A

# reverse DNS lookup
$ dig -x 11.22.33.44



