# ZeeUTao page

Use [jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) as a Jekyll theme for GitHub Pages. 



## Requirement

### jq

install [chocolatey](https://chocolatey.org/install) and run

```bash
choco install jq
```



## Run

### create categories

In git bash, run

```bash
./_scripts/sh/create_pages.sh
```



### Previewing locally

Before that you need install [Ruby](http://www.ruby-lang.org/en/downloads/), [RubyGems](http://rubygems.org/pages/download), and [Jekyll](http://jekyll.bootcss.com/)

```
gem install jekyll  
```



You may want to preview the site contents before publishing, so just run in cmd:

```bash
bundle exec jekyll s
```

Then open a browser and visit to [http://localhost:4000](http://localhost:4000/).



If any other dependency required, use `gem install xxxx  `



### Deposit in Tencent cloud

install [cloudbase cli](https://docs.cloudbase.net/cli-v1/install.html#1--an-zhuang-node-js)

```bash
npm i -g @cloudbase/cli@beta
```

login

```bash
tcb login
```

deploy

```
tcb hosting deploy [filePath] -e [cloudPath]
```

`[cloudPath]` is environment ID of Tencent cloud

