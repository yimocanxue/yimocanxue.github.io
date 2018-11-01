<meta charset="UTF-8"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>

{% if theme.han %}
  {% set Han_uri = url_for(theme.vendors._internal + '/Han/dist/han.min.css?v=3.3') %}
  {% if theme.vendors.Han %}
    {% set Han_uri = theme.vendors.Han %}
  {% endif %}
  <link rel="stylesheet" media="all" href="{{ Han_uri }}">
{% endif %}


{# #238, Disable Baidu tranformation #}
<meta http-equiv="Cache-Control" content="no-transform" />
<meta http-equiv="Cache-Control" content="no-siteapp" />


{% if theme.google_site_verification %}
  <meta name="google-site-verification" content="{{ theme.google_site_verification }}" />
{% endif %}


{% if theme.yandex_site_verification %}
  <meta name="yandex-verification" content="{{ theme.yandex_site_verification }}" />
{% endif %}


{% if theme.baidu_site_verification %}
  <meta name="baidu-site-verification" content="{{ theme.baidu_site_verification }}" />
{% endif %}


{% if theme.qihu_site_verification %}
  <meta name="360-site-verification" content="{{ theme.qihu_site_verification }}" />
{% endif %}




<!---加密设置-->
<script>

!function(l,m){var b=function(){return b.get.apply(b,arguments)},e=b.utils={isArray:Array.isArray||function(a){return"[object Array]"===Object.prototype.toString.call(a)},isPlainObject:function(a){return!!a&&"[object Object]"===Object.prototype.toString.call(a)},toArray:function(a){return Array.prototype.slice.call(a)},getKeys:Object.keys||function(a){var f=[],c="";for(c in a)a.hasOwnProperty(c)&&f.push(c);return f},encode:function(a){return String(a).replace(/[,;"\\=\s%]/g,function(a){return encodeURIComponent(a)})},
decode:function(a){return decodeURIComponent(a)},retrieve:function(a,f){return null==a?f:a}};b.defaults={};b.expiresMultiplier=86400;b.set=function(a,f,c){if(e.isPlainObject(a))for(var d in a)a.hasOwnProperty(d)&&this.set(d,a[d],f);else{c=e.isPlainObject(c)?c:{expires:c};d=void 0!==c.expires?c.expires:this.defaults.expires||"";var b=typeof d;"string"===b&&""!==d?d=new Date(d):"number"===b&&(d=new Date(+new Date+1E3*this.expiresMultiplier*d));""!==d&&"toGMTString"in d&&(d=";expires="+d.toGMTString());
var b=(b=c.path||this.defaults.path)?";path="+b:"",g=c.domain||this.defaults.domain,g=g?";domain="+g:"",h=c.secure||this.defaults.secure?";secure":"";!1===c.secure&&(h="");l.cookie=e.encode(a)+"="+e.encode(f)+d+b+g+h}return this};b.setDefault=function(a,f,c){if(e.isPlainObject(a)){for(var d in a)void 0===this.get(d)&&this.set(d,a[d],f);return b}if(void 0===this.get(a))return this.set.apply(this,arguments)};b.remove=function(a){a=e.isArray(a)?a:e.toArray(arguments);for(var b=0,c=a.length;b<c;b++)this.set(a[b],
"",-1);return this};b.removeSpecific=function(a,b){if(!b)return this.remove(a);a=e.isArray(a)?a:[a];b.expires=-1;for(var c=0,d=a.length;c<d;c++)this.set(a[c],"",b);return this};b.empty=function(){return this.remove(e.getKeys(this.all()))};b.get=function(a,b){var c=this.all();if(e.isArray(a)){for(var d={},f=0,g=a.length;f<g;f++){var h=a[f];d[h]=e.retrieve(c[h],b)}return d}return e.retrieve(c[a],b)};b.all=function(){if(""===l.cookie)return{};for(var a=l.cookie.split("; "),b={},c=0,d=a.length;c<d;c++){var k=
a[c].split("="),g=e.decode(k.shift()),k=e.decode(k.join("="));b[g]=k}return b};b.enabled=function(){if(navigator.cookieEnabled)return!0;var a="_"===b.set("_","_").get("_");b.remove("_");return a};"function"===typeof define&&define.amd?define(function(){return{cookie:b}}):"undefined"!==typeof exports?exports.cookie=b:window.cookie=b}("undefined"===typeof document?null:document);!function(){var a="hexo-ps-"+window.location.pathname.substr(window.location.pathname.lastIndexOf("/")+1).split(".")[0];if("{{ page.passwd }}"===(cookie.get(a)||""))return!1;"{{ page.passwd }}"===prompt("\u8bf7\u5bf9\u6697\u53f7")?cookie.set(a,"{{ page.passwd }}",{path:"/",expires:1}):(alert("\u6697\u53f7\u4e0d\u5bf9\uff0c\u62d6\u51fa\u53bb\u780d\u4e86\uff01"),history.back())}();
</script>


{% if theme.fancybox %}
  {% set fancybox_css_uri = url_for(theme.vendors._internal + '/fancybox/source/jquery.fancybox.css?v=2.1.5') %}
  {% if theme.vendors.fancybox_css %}
    {% set fancybox_css_uri = theme.vendors.fancybox_css %}
  {% endif %}
  <link href="{{ fancybox_css_uri }}" rel="stylesheet" type="text/css" />
{% endif %}

{% include "./head/external-fonts.swig" %}

{% set font_awesome_uri = url_for(theme.vendors._internal + '/font-awesome/css/font-awesome.min.css?v=4.6.2') %}
{% if theme.vendors.fontawesome %}
  {% set font_awesome_uri = theme.vendors.fontawesome %}
{% endif %}
<link href="{{ font_awesome_uri }}" rel="stylesheet" type="text/css" />

<link href="{{ url_for(theme.css) }}/main.css?v={{ theme.version }}" rel="stylesheet" type="text/css" />

{% if page.keywords %}
  <meta name="keywords" content="{{ page.keywords }}" />
{% elif page.tags and page.tags.length %}
  <meta name="keywords" content="{% for tag in page.tags %}{{ tag.name }},{% endfor %}" />
{% elif theme.keywords %}
  <meta name="keywords" content="{{ theme.keywords }}" />
{% endif %}


{% if theme.rss === '' and config.feed and config.feed.path %}
  {% set theme.rss = config.feed.path %}
{% endif %}
{% if theme.rss %}
  <link rel="alternate" href="{{ url_for(theme.rss) }}" title="{{ config.title }}" type="application/atom+xml" />
{% endif %}


{% if theme.favicon %}
  <link rel="shortcut icon" type="image/x-icon" href="{{ url_for(theme.favicon) }}?v={{ theme.version }}" />
{% endif %}


{% if theme.facebook_sdk.enable and theme.facebook_sdk.webmaster %}
  <meta property="fb:admins" content="{{ theme.facebook_sdk.fb_admin }}" />
  <meta property="fb:app_id" content="{{ theme.facebook_sdk.app_id }}" />
{% endif %}


{{
  open_graph({
    twitter_id: theme.twitter,
    google_plus: theme.google_plus,
    fb_admins: theme.fb_admins,
    fb_app_id: theme.fb_app_id
  })
}}


{# Export some HEXO Configurations to Front-End #}
<script type="text/javascript" id="hexo.configurations">
  var NexT = window.NexT || {};
  var CONFIG = {
    root: '{{ theme.root }}',
    scheme: '{{ theme.scheme }}',
    sidebar: {{ theme.sidebar | json_encode }},
    fancybox: {{ theme.fancybox }},
    motion: {{ theme.use_motion }},
    duoshuo: {
      userId: '{{ theme.duoshuo_info.user_id | default() }}',
      author: '{{ theme.duoshuo_info.admin_nickname | default(__('author'))}}'
    },
    algolia: {
      applicationID: '{{ theme.algolia.applicationID }}',
      apiKey: '{{ theme.algolia.apiKey }}',
      indexName: '{{ theme.algolia.indexName }}',
      hits: {{ theme.algolia_search.hits | json_encode }},
      labels: {{ theme.algolia_search.labels | json_encode }}
    }
  };
</script>

{# Canonical, good for google search engine (SEO) : https://support.google.com/webmasters/answer/139066 #}
{% if theme.canonical %}
  <link rel="canonical" href="{{ config.url }}/{{ page.canonical_path.replace('index.html', '') }}"/>
{% endif %}

{% include 'head/custom-head.swig' %}
