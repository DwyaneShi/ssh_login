# ssh_login
```shell
+----+------------+------+-----------------+
| ID | SHORT NAME | USER | ADDRESS         |
+----+------------+------+-----------------+
| 1 | SRV0 | user | srv0.domain.com |
|   |      |      |                 |
| 2 | SRV1 | user | srv1.domain.com |
|   |      |      |                 |
| 3 | SRV2 | user | srv2.domain.com |
+----+------------+------+-----------------+

TO LOGIN CLUSTER ID: [1-3]
2
Logging in SRV1...
spawn ssh -p 22 user@srv1.domain.com
Last login: Sat Apr 15 02:48:36 2017 from 74.140.4.58

user@srv1.domain.com: exit

logout
Connection to srv1.domain.com
Exit SRV1
```


Thanks to [SSHAutoLogin](https://github.com/jiangxianli/SSHAutoLogin) and [ASCII Cells](https://github.com/mitnk/asciicells).
