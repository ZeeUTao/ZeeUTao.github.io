# ZeeUTao page

Use [jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) as a Jekyll theme for GitHub Pages. 



### Previewing locally

Before that you need install [Ruby](http://www.ruby-lang.org/en/downloads/), [RubyGems](http://rubygems.org/pages/download), and [Jekyll](http://jekyll.bootcss.com/)

```
gem install jekyll  
```



- Run `bundle exec jekyll serve` to start the preview server
- Visit [`localhost:4000`](http://localhost:4000) in your browser to preview the theme



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

