# Nginx-Acme

### 1. 介绍

Nginx-Acme - 本镜像基于 nginx-apline 基础镜像安装 acme.sh 以实现 SSL 自动申请证书

### 2. docker 安装

#### 2.1 命令行方式

```bash
docker run -d --name nginx-acme -p 80:80 -p 443:443 \
-v acmecerts:/acmecerts \
-v nginx-conf:/nginx-conf \
-v log:/var/log \
ghcr.io/jaimeqian/nginx-acme:latest
```

#### 2.2 docker-compose 方式

```yaml
version: '3.9'

services:
  nginx-acme:
    image: ghcr.io/jaimeqian/nginx-acme:latest
    container_name: nginx-acme
    restart: always
    ports:
      - 443:443
      - 80:80
    volumes:
      - acmecerts:/acmecerts
      - nginx-conf:/nginx-conf
      - log:/var/log

volumes:
  acmecerts:
  nginx-conf:
  log:
```

### 3. 目录说明

- /acmecerts **acme.sh 配置和生成证书**
- /nginx-conf/certs **nginx 证书存放位置**
- /nginx/wwwroot **nginx 站点存放位置**
- /nginx-conf/conf.d **nginx 虚拟主机配置文件以.conf 结尾**
- /nginx-conf/stream.d **nginx 均衡负载配置文件以.conf 结尾**
- /var/log **日志**

### 4. 使用说明

#### 4.1 生成证书

acme.sh 实现了 acme 协议支持的所有验证协议. 一般有两种方式验证: http 和 dns 验证.

http 方式需要在你的网站根目录下放置一个文件, 来验证你的域名所有权,完成验证. 然后就可以生成证书了.

```bash
docker exec nginx-acme \
/acme.sh/acme.sh --issue -d mydomain.com -d www.mydomain.com \
--webroot /nginx/wwwroot/mydomain.com/
```

只需要指定域名, 并指定域名所在的网站根目录. acme.sh 会全自动的生成验证文件, 并放到网站的根目录, 然后自动完成验证. 最后会聪明的删除验证文件. 整个过程没有任何副作用.

#### 4.2 copy/安装 证书

前面证书生成以后, 接下来需要把证书 copy 到真正需要用它的地方.

注意, 默认生成的证书都放在配置目录下: /acmecerts/, 请不要直接使用此目录下的文件, 例如: 不要直接让 nginx/apache 的配置文件使用这下面的文件. 这里面的文件都是内部使用, 而且目录结构可能会变化.

正确的使用方法是使用 --install-cert 命令,并指定目标位置, 然后证书文件会被 copy 到相应的位置, 例如:

```bash
docker exec nginx-acme \
/acme.sh/acme.sh --install-cert -d mydomain.com \
--key-file       /nginx/certs/mydomain.com/privkey.pem  \
--fullchain-file /nginx/certs/mydomain.com/fullchain.pem \
--reloadcmd     "nginx -t && nginx -s reload"
```

其他生成方式请参考 acme.sh 官网 https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E
