// ==========================================
// 中国油价 Widget for Scriptable
//
// Widget Parameter：
// 江苏|95
// 上海|92
// 广东|98
//
// 地区 | 关注油号
// ==========================================

const DEFAULT_REGION = "江苏";
const DEFAULT_FUEL = "95";

const API_URL =
  "https://v1.apizero.cn/api/oil-price";


// ==========================================
// 颜色
// ==========================================

const COLORS = {

  bg: Color.dynamic(
    new Color("#F5F5F7"),
    new Color("#171719")
  ),

  primary: Color.dynamic(
    new Color("#111111"),
    new Color("#FFFFFF")
  ),

  secondary: Color.dynamic(
    new Color("#6E6E73"),
    new Color("#A1A1A6")
  ),

  green:
    new Color("#34C759"),

  red:
    new Color("#FF3B30"),

  orange:
    new Color("#FF9500")
};


// ==========================================
// 读取 Widget 参数
// ==========================================

function parseParameter() {

  const raw =
    (args.widgetParameter || "")
      .trim();

  if (!raw) {

    return {
      region: DEFAULT_REGION,
      fuel: DEFAULT_FUEL
    };
  }

  const parts =
    raw
      .split("|")
      .map(x => x.trim());

  const region =
    parts[0] ||
    DEFAULT_REGION;

  const fuel =
    ["92", "95", "98", "0"]
      .includes(parts[1])
      ? parts[1]
      : DEFAULT_FUEL;

  return {
    region,
    fuel
  };
}


// ==========================================
// 安全文件名
// ==========================================

function safeName(s) {

  return s.replace(
    /[^a-zA-Z0-9_\-\u4e00-\u9fff]/g,
    "_"
  );
}


// ==========================================
// API 数据转价格 Map
// ==========================================

function priceMap(data) {

  const map = {};

  for (
    const item of
    (data?.prices || [])
  ) {

    if (
      item.type ===
      "gasoline_92"
    ) {
      map["92"] =
        Number(item.price);
    }

    if (
      item.type ===
      "gasoline_95"
    ) {
      map["95"] =
        Number(item.price);
    }

    if (
      item.type ===
      "gasoline_98"
    ) {
      map["98"] =
        Number(item.price);
    }

    if (
      item.type ===
      "diesel_0"
    ) {
      map["0"] =
        Number(item.price);
    }
  }

  return map;
}


// ==========================================
// 判断油价是否变化
// ==========================================

function pricesChanged(
  oldPrices,
  newPrices
) {

  for (
    const fuel of
    ["92", "95", "98", "0"]
  ) {

    if (
      Number.isFinite(
        oldPrices?.[fuel]
      )
      &&
      Number.isFinite(
        newPrices?.[fuel]
      )
      &&
      Math.abs(
        oldPrices[fuel]
        -
        newPrices[fuel]
      ) >= 0.005
    ) {
      return true;
    }
  }

  return false;
}


// ==========================================
// 解析下次调价时间
//
// 示例：
// 下次油价9月24日24时调整
// ==========================================

function parseAdjustment(text) {

  if (!text) {
    return null;
  }

  const match =
    text.match(
      /(?:(\d{4})年)?(\d{1,2})月(\d{1,2})日(?:\s*(\d{1,2})时)?/
    );

  if (!match) {
    return null;
  }

  const now =
    new Date();

  let year =
    match[1]
      ? Number(match[1])
      : now.getFullYear();

  const month =
    Number(match[2]);

  const day =
    Number(match[3]);

  const hour =
    match[4]
      ? Number(match[4])
      : 24;


  // 北京时间 → UTC
  let target =
    new Date(
      Date.UTC(
        year,
        month - 1,
        day,
        hour - 8,
        0,
        0
      )
    );


  // 跨年处理
  if (
    !match[1]
    &&
    target.getTime()
    <
    now.getTime()
    -
    7 * 86400000
  ) {

    year += 1;

    target =
      new Date(
        Date.UTC(
          year,
          month - 1,
          day,
          hour - 8,
          0,
          0
        )
      );
  }


  return {

    target,

    label:
      `${month}/${day} ${
        String(hour)
          .padStart(2, "0")
      }:00`,

    raw: text
  };
}


// ==========================================
// 解析预测
// ==========================================

function forecastInfo(text) {

  const raw =
    text ||
    "暂无预测";

  let kind =
    "flat";

  let icon =
    "—";

  let color =
    COLORS.secondary;

  let advice =
    "等待下一轮测算";


  // 上调
  if (
    /上调|上涨/.test(raw)
  ) {

    kind =
      "up";

    icon =
      "↑";

    color =
      COLORS.red;

    advice =
      "近期加油可关注调价前";
  }


  // 下调
  else if (
    /下调|下跌/.test(raw)
  ) {

    kind =
      "down";

    icon =
      "↓";

    color =
      COLORS.green;

    advice =
      "不着急可关注调价后";
  }


  // 搁浅
  else if (
    /搁浅|不调整|暂不调整/
      .test(raw)
  ) {

    advice =
      "预计本轮变化不大";
  }


  // --------------------------------
  // 尝试提取 元/升
  // --------------------------------

  const range =
    raw.match(
      /([0-9.]+)元\/升\s*[-~至—–]\s*([0-9.]+)元\/升/
    );

  const single =
    raw.match(
      /([0-9.]+)元\/升/
    );

  const ton =
    raw.match(
      /([0-9.]+)元\/吨/
    );


  let summary =
    raw;


  if (range) {

    summary =
      `${icon} ${range[1]}–${range[2]} 元/L`;

  }

  else if (single) {

    summary =
      `${icon} ${single[1]} 元/L`;

  }

  else if (ton) {

    summary =
      `${icon} ${ton[1]} 元/吨`;

  }

  else if (
    kind === "up"
  ) {

    summary =
      "↑ 预计上调";

  }

  else if (
    kind === "down"
  ) {

    summary =
      "↓ 预计下调";

  }

  else if (
    /搁浅/.test(raw)
  ) {

    summary =
      "— 预计搁浅";
  }


  return {
    raw,
    kind,
    summary,
    color,
    advice
  };
}


// ==========================================
// 北京时间
// ==========================================

function chinaTimeParts(date) {

  const d =
    new Date(
      date.getTime()
      +
      8 * 3600000
    );

  return {

    month:
      d.getUTCMonth() + 1,

    day:
      d.getUTCDate(),

    hour:
      d.getUTCHours(),

    minute:
      d.getUTCMinutes()
  };
}


// ==========================================
// 格式化拉取时间
// ==========================================

function formatFetchTime(ms) {

  const p =
    chinaTimeParts(
      new Date(ms)
    );

  return (
    String(p.hour)
      .padStart(2, "0")
    +
    ":"
    +
    String(p.minute)
      .padStart(2, "0")
  );
}


// ==========================================
// 智能刷新
//
// 平时：4小时
// 调价前24小时：1小时
// 调价前后3小时：30分钟
// ==========================================

function refreshInterval(
  adjustment
) {

  if (!adjustment) {

    return (
      4 *
      60 *
      60 *
      1000
    );
  }


  const diff =
    adjustment.target
      .getTime()
    -
    Date.now();


  // 调价前后 3 小时
  if (
    diff <=
      3 * 3600000
    &&
    diff >
      -3 * 3600000
  ) {

    return (
      30 *
      60 *
      1000
    );
  }


  // 调价前 24 小时
  if (
    diff <=
      24 * 3600000
    &&
    diff > 0
  ) {

    return (
      60 *
      60 *
      1000
    );
  }


  return (
    4 *
    60 *
    60 *
    1000
  );
}


// ==========================================
// 请求 API
// ==========================================

async function fetchOil(region) {

  const req =
    new Request(
      API_URL
    );

  req.method =
    "POST";

  req.timeoutInterval =
    12;

  req.headers = {

    "Content-Type":
      "application/json"
  };

  req.body =
    JSON.stringify({

      province: region
    });


  const json =
    await req.loadJSON();


  if (
    json.code !== 0
    ||
    !json.data
  ) {

    throw new Error(
      json.msg
      ||
      `API code ${json.code}`
    );
  }


  return json.data;
}


// ==========================================
// 添加文字
// ==========================================

function addText(
  container,
  text,
  size,
  weight = "regular",
  color = COLORS.primary
) {

  const t =
    container.addText(
      String(text)
    );


  if (
    weight === "bold"
  ) {

    t.font =
      Font.boldSystemFont(
        size
      );

  }

  else if (
    weight === "medium"
  ) {

    t.font =
      Font.mediumSystemFont(
        size
      );

  }

  else {

    t.font =
      Font.systemFont(
        size
      );
  }


  t.textColor =
    color;

  t.minimumScaleFactor =
    0.7;

  t.lineLimit =
    1;


  return t;
}


// ==========================================
// 小标签
// ==========================================

function addPill(
  container,
  text,
  color
) {

  const pill =
    container.addStack();

  pill.setPadding(
    3,
    7,
    3,
    7
  );

  pill.cornerRadius =
    8;

  pill.backgroundColor =
    Color.dynamic(

      new Color(
        "#E5E5EA",
        0.8
      ),

      new Color(
        "#3A3A3C",
        0.8
      )
    );


  addText(
    pill,
    text,
    9,
    "medium",
    color
  );


  return pill;
}


// ==========================================
// 油价一行
//
// 所有油号、价格样式完全一致
// ==========================================

function addPriceRow(
  container,
  fuel,
  value,
  previous
) {

  const row =
    container.addStack();

  row.layoutHorizontally();

  row.centerAlignContent();


  // 左边油号
  addText(
    row,

    fuel === "0"
      ? "0#柴油"
      : `${fuel}#`,

    12,

    "medium",

    COLORS.secondary
  );


  row.addSpacer();


  // 右边价格
  addText(
    row,

    Number.isFinite(value)
      ?
      `¥ ${value.toFixed(2)}`
      :
      "--",

    16,

    "medium",

    COLORS.primary
  );


  // 最近一次价格变化
  if (
    Number.isFinite(value)
    &&
    Number.isFinite(previous)
  ) {

    const delta =
      value -
      previous;


    if (
      Math.abs(delta)
      >=
      0.005
    ) {

      row.addSpacer(5);


      addText(
        row,

        `${delta > 0 ? "+" : ""}${delta.toFixed(2)}`,

        9,

        "medium",

        delta > 0
          ?
          COLORS.red
          :
          COLORS.green
      );
    }
  }
}


// ==========================================
// 小号 Widget
// ==========================================

function makeSmallWidget(ctx) {

  const {

    data,
    map,
    adjustment,
    forecast,
    region,
    fuel,
    cacheUsed,
    fetchedAt

  } = ctx;


  const w =
    new ListWidget();


  w.backgroundColor =
    COLORS.bg;


  w.setPadding(
    14,
    14,
    13,
    14
  );


  // --------------------------------
  // Header
  // --------------------------------

  const header =
    w.addStack();

  header.centerAlignContent();


  addText(
    header,

    `⛽ ${data.province || region}`,

    14,

    "bold"
  );


  header.addSpacer();


  addText(
    header,

    cacheUsed
      ? "缓存"
      : "最新",

    9,

    "medium",

    cacheUsed
      ?
      COLORS.secondary
      :
      COLORS.green
  );


  w.addSpacer(10);


  // --------------------------------
  // 关注油号
  // --------------------------------

  addText(
    w,

    fuel === "0"
      ?
      "0# 柴油"
      :
      `${fuel}# 汽油`,

    11,

    "medium",

    COLORS.secondary
  );


  w.addSpacer(2);


  addText(
    w,

    Number.isFinite(
      map[fuel]
    )
      ?
      `¥ ${map[fuel].toFixed(2)}`
      :
      "--",

    23,

    "medium",

    COLORS.primary
  );


  w.addSpacer(10);


  // --------------------------------
  // 预测
  // --------------------------------

  const forecastRow =
    w.addStack();


  addPill(
    forecastRow,

    forecast.summary,

    forecast.color
  );


  w.addSpacer(9);


  // --------------------------------
  // 下次调价
  // --------------------------------

  addText(
    w,

    "下次调价",

    9,

    "medium",

    COLORS.secondary
  );


  if (adjustment) {

    addText(
      w,

      adjustment.label,

      12,

      "medium",

      COLORS.primary
    );

  }

  else {

    addText(
      w,

      "暂无数据",

      12,

      "medium",

      COLORS.secondary
    );
  }


  w.addSpacer();


  // --------------------------------
  // Footer
  // --------------------------------

  addText(
    w,

    `${data.update_date || "--"} · ${formatFetchTime(fetchedAt)}`,

    8,

    "regular",

    COLORS.secondary
  );


  return w;
}


// ==========================================
// 中号 Widget
// ==========================================

function makeMediumWidget(ctx) {

  const {

    data,
    map,
    previous,
    adjustment,
    forecast,
    region,
    cacheUsed,
    fetchedAt

  } = ctx;


  const w =
    new ListWidget();


  w.backgroundColor =
    COLORS.bg;


  w.setPadding(
    14,
    16,
    12,
    16
  );


  // ======================================
  // Header
  // ======================================

  const header =
    w.addStack();

  header.centerAlignContent();


  addText(
    header,

    `⛽ ${data.province || region}油价`,

    13,

    "medium",

    COLORS.primary
  );


  header.addSpacer();


  addPill(
    header,

    cacheUsed
      ?
      "缓存"
      :
      "已更新",

    cacheUsed
      ?
      COLORS.secondary
      :
      COLORS.green
  );


  w.addSpacer(11);


  // ======================================
  // Body
  // ======================================

  const body =
    w.addStack();

  body.layoutHorizontally();


  // ======================================
  // 左侧：油价
  // ======================================

  const left =
    body.addStack();

  left.layoutVertically();

  left.size =
    new Size(
      132,
      0
    );


  addPriceRow(
    left,
    "92",
    map["92"],
    previous?.["92"]
  );


  left.addSpacer(6);


  addPriceRow(
    left,
    "95",
    map["95"],
    previous?.["95"]
  );


  left.addSpacer(6);


  addPriceRow(
    left,
    "98",
    map["98"],
    previous?.["98"]
  );


  left.addSpacer(6);


  addPriceRow(
    left,
    "0",
    map["0"],
    previous?.["0"]
  );


  // ======================================
  // 中间间隔自适应，让两侧逻辑块分别对齐
  // 到中号 Widget 的左右半区
  // ======================================

  body.addSpacer();


  // ======================================
  // 右侧
  // ======================================

  const right =
    body.addStack();

  right.layoutVertically();

  right.size =
    new Size(
      132,
      0
    );


  // --------------------------------
  // 下次调价
  // --------------------------------

  addText(
    right,

    "下次调价",

    10,

    "medium",

    COLORS.secondary
  );


  right.addSpacer(2);


  if (adjustment) {

    addText(
      right,

      adjustment.label,

      15,

      "medium",

      COLORS.primary
    );

  }

  else {

    addText(
      right,

      "暂无数据",

      14,

      "medium",

      COLORS.secondary
    );
  }


  right.addSpacer(12);


  // --------------------------------
  // 本轮预测
  // --------------------------------

  addText(
    right,

    "本轮预测",

    10,

    "medium",

    COLORS.secondary
  );


  right.addSpacer(2);


  addText(
    right,

    forecast.summary,

    13,

    "medium",

    forecast.color
  );


  right.addSpacer(4);


  const advice =
    addText(
      right,

      forecast.advice,

      9,

      "regular",

      COLORS.secondary
    );


  advice.lineLimit =
    2;


  // ======================================
  // Footer
  // ======================================

  w.addSpacer();


  const footer =
    w.addStack();


  addText(
    footer,

    `数据 ${data.update_date || "--"}`,

    8,

    "regular",

    COLORS.secondary
  );


  footer.addSpacer();


  addText(
    footer,

    `拉取 ${formatFetchTime(fetchedAt)}${cacheUsed ? " · 缓存" : ""}`,

    8,

    "regular",

    COLORS.secondary
  );


  return w;
}


// ==========================================
// 主程序
// ==========================================

async function main() {

  const {
    region,
    fuel
  } =
    parseParameter();


  const fm =
    FileManager.local();


  const stateFile =
    fm.joinPath(

      fm.documentsDirectory(),

      `oil-widget-${safeName(region)}.json`
    );


  // ======================================
  // 读取缓存
  // ======================================

  let state =
    null;


  if (
    fm.fileExists(
      stateFile
    )
  ) {

    try {

      state =
        JSON.parse(

          fm.readString(
            stateFile
          )
        );

    }

    catch (_) {

      state =
        null;
    }
  }


  // ======================================
  // 当前刷新策略
  // ======================================

  const cachedAdjustment =
    parseAdjustment(
      state?.data
        ?.next_adjustment
    );


  const interval =
    refreshInterval(
      cachedAdjustment
    );


  // ======================================
  // 在 Scriptable 里手动运行时
  // 强制联网刷新
  // ======================================

  const forceNetwork =
    !config.runsInWidget;


  const cacheAge =

    state?.fetchedAt

      ?
      Date.now()
      -
      state.fetchedAt

      :
      Infinity;


  const shouldFetch =

    forceNetwork
    ||
    !state?.data
    ||
    cacheAge >= interval;


  let data =
    state?.data ||
    null;


  let fetchedAt =
    state?.fetchedAt
    ||
    Date.now();


  let previous =
    state?.previousPrices
    ||
    null;


  let cacheUsed =
    false;


  // ======================================
  // 请求最新油价
  // ======================================

  if (shouldFetch) {

    try {

      const fresh =
        await fetchOil(
          region
        );


      const oldMap =
        priceMap(
          state?.data
        );


      const newMap =
        priceMap(
          fresh
        );


      // --------------------------------
      // 检测是否发生调价
      // --------------------------------

      if (
        state?.data
        &&
        pricesChanged(
          oldMap,
          newMap
        )
      ) {

        previous =
          oldMap;
      }


      data =
        fresh;


      fetchedAt =
        Date.now();


      state = {

        data,

        fetchedAt,

        previousPrices:
          previous
      };


      fm.writeString(

        stateFile,

        JSON.stringify(
          state
        )
      );

    }

    catch (error) {

      // API 挂了
      // 如果有缓存则继续显示

      if (!data) {
        throw error;
      }


      cacheUsed =
        true;
    }
  }


  // ======================================
  // 数据处理
  // ======================================

  const map =
    priceMap(
      data
    );


  const adjustment =
    parseAdjustment(
      data.next_adjustment
    );


  const forecast =
    forecastInfo(
      data.forecast
    );


  const ctx = {

    data,

    map,

    previous,

    adjustment,

    forecast,

    region,

    fuel,

    cacheUsed,

    fetchedAt
  };


  // ======================================
  // 根据 Widget 尺寸创建
  // ======================================

  const family =
    config.widgetFamily
    ||
    "medium";


  let widget;


  if (
    family === "small"
  ) {

    widget =
      makeSmallWidget(
        ctx
      );

  }

  else {

    widget =
      makeMediumWidget(
        ctx
      );
  }


  // ======================================
  // 点击 Widget
  // 打开 Scriptable 手动刷新
  // ======================================

  widget.url =

    `scriptable:///run?scriptName=${
      encodeURIComponent(
        Script.name()
      )
    }`;


  // ======================================
  // 自动刷新
  // ======================================

  widget.refreshAfterDate =

    new Date(

      Date.now()
      +
      refreshInterval(
        adjustment
      )
    );


  // ======================================
  // 输出
  // ======================================

  if (
    config.runsInWidget
  ) {

    Script.setWidget(
      widget
    );

  }

  else {

    if (
      family === "small"
    ) {

      await widget.presentSmall();

    }

    else {

      await widget.presentMedium();
    }
  }


  Script.complete();
}


// ==========================================
// 错误页面
// ==========================================

try {

  await main();

}

catch (error) {

  const w =
    new ListWidget();


  w.backgroundColor =
    COLORS.bg;


  w.setPadding(
    14,
    14,
    14,
    14
  );


  addText(
    w,
    "⛽ 油价",
    16,
    "bold"
  );


  w.addSpacer(10);


  addText(
    w,
    "数据获取失败",
    14,
    "medium",
    COLORS.red
  );


  w.addSpacer(5);


  const message =
    addText(
      w,

      String(
        error.message
        ||
        error
      ),

      10,

      "regular",

      COLORS.secondary
    );


  message.lineLimit =
    4;


  if (
    config.runsInWidget
  ) {

    Script.setWidget(
      w
    );

  }

  else {

    await w.presentMedium();
  }


  Script.complete();
}
