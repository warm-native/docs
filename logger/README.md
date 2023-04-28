# logger

- [logger](#logger)
  - [Loki](#loki)
    - [what is Loki](#what-is-loki)
    - [设计思想](#设计思想)
    - [日志采集的方式](#日志采集的方式)
    - [日志存储方式](#日志存储方式)
    - [日志检索](#日志检索)
      - [a filter expression](#a-filter-expression)
    - [Best Prictices](#best-prictices)

## Loki

### what is Loki

Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system.

### 设计思想

- does not do full text indexing on logs. By storing compressed, unstructured logs and only ta metadata, Loki is simpler to operate and cheaper to run.
- indexes and groups log streams using the same labels you’re already using with Prometheus, enabling you to seamlessly switch between metrics and logs using the same labels that you’re already using with Prometheus.
- is an especially good fit for storing Kubernetes Pod logs. Metadata such as Pod labels is automatically scraped and indexed.
- has native support in Grafana (needs Grafana v6.0).

- 日志采集的方式
- 日志存储的方式
- 日志查询（索引）的方式

The efficient indexing of log data distinguishes Loki from other logging systems. Unlike other logging systems, a Loki index is built from __labels__, leaving the original log message unindexed.

### 日志采集的方式

基于label的唯一性组合定义为stream, then batched up, compressed, and stored as chunks.

```sh
{job="apache",status_code="200"} 11.11.11.11 - frank [25/Jan/2000:14:00:01 -0500] "GET /1986.js HTTP/1.1" 200 932 "-" "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7 GTB6"
{job="apache",status_code="404"} 11.11.11.11 - frank [25/Jan/2000:14:00:01 -0500] "GET /1986.js HTTP/1.1" 200 932 "-" "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7 GTB6"
```

So, For Loki to be __efficient and cost-effective__, we have to use labels responsibly. The next section will explore this in more detail.

promtail 的 scrape_configs的配置规则：

### 日志存储方式

### 日志检索

As we see people using Loki who are accustomed to other index-heavy solutions(eg ELK), it seems like they feel obligated to define a lot of labels in order to query their logs effectively. After all, many other logging solutions are all about the index, and _this is the common way of thinking_.

但是使用Loki时，请你遗忘掉这个想法，Loki’s superpower is breaking up queries into small pieces and dispatching them in parallel so that you can query huge amounts of log data in small amounts of time.

When we talk about cardinality we are referring to the combination of labels and values and the number of streams they create.

通过合并labels,减少stream的产生，另外通过并行提供快速的查询能力。

This drives the fixed operating costs to a minimum while still allowing for incredibly fast query capability.

#### a filter expression

### Best Prictices

For any single log stream, logs must always be sent in increasing time order. If a log is received with a timestamp older than the most recent log received for that stream, that log will be dropped.
