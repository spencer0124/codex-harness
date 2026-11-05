async page => {
  const report = await page.evaluate(() => {
    const vw = document.documentElement.clientWidth;
    const vh = window.innerHeight;
    const MAX = 8;
    const path = (el) => {
      const parts = [];
      for (let e = el; e && e !== document.body && parts.length < 4; e = e.parentElement) {
        let p = e.tagName.toLowerCase();
        if (e.id) { parts.unshift(p + '#' + e.id); break; }
        const cls = typeof e.className === 'string' ? e.className.trim().split(/\s+/)[0] : '';
        if (cls) p += '.' + cls;
        const sib = e.parentElement ? [...e.parentElement.children].filter((c) => c.tagName === e.tagName) : [];
        if (sib.length > 1) p += ':nth-of-type(' + (sib.indexOf(e) + 1) + ')';
        parts.unshift(p);
      }
      return parts.join(' > ');
    };
    const text = (el) => (el.innerText || el.textContent || '').trim().replace(/\s+/g, ' ').slice(0, 40);
    const box = (r) => [Math.round(r.x), Math.round(r.y), Math.round(r.width), Math.round(r.height)];
    const visible = (el) => {
      const r = el.getBoundingClientRect();
      if (r.width < 1 || r.height < 1) return false;
      const s = getComputedStyle(el);
      return s.visibility !== 'hidden' && s.display !== 'none' && Number(s.opacity) > 0;
    };
    const scrollsX = (el) => /(auto|scroll)/.test(getComputedStyle(el).overflowX);
    const inScroller = (el) => { for (let e = el.parentElement; e && e !== document.body; e = e.parentElement) if (scrollsX(e)) return true; return false; };
    const all = [...document.body.querySelectorAll('*')].filter((el) => !['SCRIPT', 'STYLE', 'NOSCRIPT', 'TEMPLATE'].includes(el.tagName) && visible(el));
    const hasOwnText = (el) => [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());

    const offscreen = [], clipped = [], overflowParent = [], smallViews = [], overlaps = [];
    let tinyText = 0;
    for (const el of all) {
      const r = el.getBoundingClientRect();
      const s = getComputedStyle(el);
      const fixed = s.position === 'fixed';
      if (!fixed && (r.right > vw + 1 || r.left < -1) && !inScroller(el) && offscreen.length < MAX) offscreen.push({ el: path(el), box: box(r), text: text(el) });
      const clipsX = /(hidden|clip)/.test(s.overflowX), clipsY = /(hidden|clip)/.test(s.overflowY);
      if (hasOwnText(el) && s.textOverflow !== 'ellipsis' && ((clipsX && el.scrollWidth > el.clientWidth + 1) || (clipsY && el.scrollHeight > el.clientHeight + 1)) && clipped.length < MAX) clipped.push({ el: path(el), box: box(r), text: text(el) });
      const parent = el.parentElement;
      if (parent && parent !== document.body && !fixed && s.position !== 'absolute' && !scrollsX(parent) && !/(hidden|clip)/.test(getComputedStyle(parent).overflowX)) {
        const pr = parent.getBoundingClientRect();
        if (r.right > pr.right + 2 && overflowParent.length < MAX) overflowParent.push({ el: path(el), parent: path(parent), overflowPx: Math.round(r.right - pr.right) });
      }
      const want = el.dataset.uiMin;
      const isView = want || el.tagName === 'CANVAS' || (el.tagName === 'svg' && !(r.width < 64 && r.height < 64)) || /(map|chart|route|canvas|graph)/i.test(typeof el.className === 'string' ? el.className : '');
      if (isView) {
        const [mw, mh] = want ? want.split('x').map(Number) : [Math.min(320, vw - 32), 240];
        if ((r.width < mw || r.height < mh) && smallViews.length < MAX) smallViews.push({ el: path(el), size: [Math.round(r.width), Math.round(r.height)], min: [mw, mh] });
      }
      if (hasOwnText(el) && parseFloat(s.fontSize) < 12) tinyText++;
    }
    const leaves = all.filter(hasOwnText).slice(0, 500).map((el) => ({ el, r: el.getBoundingClientRect() }));
    for (let i = 0; i < leaves.length && overlaps.length < MAX; i++) {
      for (let j = i + 1; j < leaves.length && overlaps.length < MAX; j++) {
        const a = leaves[i], b = leaves[j];
        if (a.el.contains(b.el) || b.el.contains(a.el)) continue;
        const w = Math.min(a.r.right, b.r.right) - Math.max(a.r.left, b.r.left);
        const h = Math.min(a.r.bottom, b.r.bottom) - Math.max(a.r.top, b.r.top);
        if (w > 2 && h > 2) overlaps.push({ a: path(a.el), b: path(b.el), text: [text(a.el), text(b.el)], overlap: [Math.round(w), Math.round(h)] });
      }
    }
    const pageOverflowX = Math.max(0, document.documentElement.scrollWidth - vw);
    const unnamedButtons = [...document.querySelectorAll('button, [role=button], a[href]')].filter((b) => visible(b) && !(b.getAttribute('aria-label') || text(b) || b.title)).length;
    const issues = { pageOverflowX, offscreen, clipped, overflowParent, smallViews, overlaps };
    const ok = pageOverflowX <= 1 && !offscreen.length && !clipped.length && !overflowParent.length && !smallViews.length && !overlaps.length;
    return { viewport: [vw, vh], ok, issues, tinyText, unnamedButtons };
  });
  return report;
}
