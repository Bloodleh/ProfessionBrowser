// ==UserScript==
// @name         Wowhead Extractor
// @namespace    http://tampermonkey.net/
// @version      2024-11-28
// @description  try to take over the world!
// @author       You
// @match        https://www.wowhead.com/classic/spell=*
// @match        https://www.wowhead.com/classic/item=*
// @match        https://www.wowhead.com/classic/skill=*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=wowhead.com
// @grant        none
// ==/UserScript==

(function()
{
    function load()
    {
        const json = localStorage.getItem("pm_data");
        if (!json)
        {
            return {
                items: [],
                extraItemIds: [],
            };
        }
        return JSON.parse(json);
    }
    function save(data)
    {
        localStorage.setItem("pm_data", JSON.stringify(data));
    }
    function clear()
    {
        localStorage.removeItem("pm_data");
        console.log("CLEARED ALL PM DATA");
    }

    function getWowheadId(type, url)
    {
        const r = new RegExp('^https\:\/\/www\.wowhead\.com\/classic\/' + type + '\=(\\d+)\/', "i");
        const res = url.match(r);
        if (!res) return null;
        return !!res[1] ? parseInt(res[1]) : null;
    }

    // Example:
    // https://www.wowhead.com/classic/skill=202/engineering#recipes;0+18+1
    function getWowheadListItems()
    {
        const res = load();
        const resItems = res.items;

        const rows = document.querySelectorAll(".listview-row");

        for (let i = 0; i < rows.length; i++)
        {
            const row = rows[i];

            const newItem = {
                itemId: null,
                spellId: null,
                name: null,
                count: null, // null = single
                type: null,
                mats: [],
                lvl: {
                    req: null, // learn level
                    r1: null, // orange
                    r2: null, // yellow
                    r3: null, // green
                    r4: null, // gray
                }
            };

            //console.log(row);

            const tds = row.querySelectorAll("td");

            const iconTd = tds[0] || null;
            const nameTd = tds[1] || null;
            const reagentsTd = tds[3] || null;
            const skillTd = tds[5] || null;

            if (iconTd)
            {
                const a = iconTd.querySelector("a");
                const href = a.href;
                newItem.itemId = getWowheadId("item", href);

                const span = iconTd.querySelector("span[data-type='number']");

                if (span)
                {
                    newItem.count = span.textContent;
                }

                //console.log(href, itemId, count);
            }

            if (nameTd)
            {
                const a = nameTd.querySelector("a");
                const href = a.href;
                newItem.spellId = getWowheadId("spell", href);
                newItem.name = a.textContent.trim();

                //console.log(href, name, spellId);
            }

            if (reagentsTd)
            {
                const reagentElems = reagentsTd.querySelectorAll(".iconmedium");

                //console.log(reagentsTd);

                for (let j = 0; j < reagentElems.length; j++)
                {
                    const reagentElem = reagentElems[j];

                    const a = reagentElem.querySelector("a");
                    const href = a.href;

                    const reagentItemId = getWowheadId("item", href);
                    let reagentItemCount = 1;

                    //console.log(href, reagentItemId);

                    const span = reagentElem.querySelector("span");
                    if (span)
                    {
                        reagentItemCount = parseInt(span.textContent);
                    }

                    newItem.mats.push({
                        itemId: reagentItemId,
                        count: reagentItemCount,
                    });

                    res.extraItemIds.push(reagentItemId);
                }

                //console.log(newItem.mats);
            }

            if (skillTd)
            {
                const tdText = skillTd.textContent.trim();
                const tdMatch = tdText.match(/([^\(]+)\((\d+)/i);

                //console.log(skillTd, tdText, tdMatch);

                if (tdMatch)
                {
                    newItem.type = tdMatch[1] ? tdMatch[1].trim() : null;
                    newItem.lvl.req = tdMatch[2] ? parseInt(tdMatch[2]) : null;
                }

                const r1 = skillTd.querySelector("span.r1");
                const r2 = skillTd.querySelector("span.r2");
                const r3 = skillTd.querySelector("span.r3");
                const r4 = skillTd.querySelector("span.r4");

                if (r1)
                {
                    newItem.lvl.r1 = parseInt(r1.textContent);
                }
                if (r2)
                {
                    newItem.lvl.r2 = parseInt(r2.textContent);
                }
                if (r3)
                {
                    newItem.lvl.r3 = parseInt(r3.textContent);
                }
                if (r4)
                {
                    newItem.lvl.r4 = parseInt(r4.textContent);
                }
            }

            if (!newItem.itemId || !newItem.name || !newItem.spellId || !newItem.lvl.req)
            {
                continue;
            }

            let exists = false;

            for (let k = 0; k < resItems.length; k++)
            {
                if (resItems[k].itemId === newItem.itemId)
                {
                    exists = true;
                    break;
                }
            }

            if (exists)
            {
                continue;
            }

            resItems.push(newItem);
        }

        save(res);
        console.log("DATA:", load());
    }

    function normalize()
    {
        const res = load();
        const resItems = res.items;
        const resExtraItemIds = res.extraItemIds;

        const newExtraItemIds = [];

        for (let i = 0; i < resExtraItemIds.length; i++)
        {
            const extraItemId = resExtraItemIds[i];

            let exists = false;

            for (let j = 0; j < resItems.length; j++)
            {
                const item = resItems[j];

                if (item.itemId === extraItemId)
                {
                    exists = true;
                    break;
                }
            }

            if (!exists && newExtraItemIds.indexOf(extraItemId) === -1)
            {
                newExtraItemIds.push(extraItemId);
            }
        }

        res.extraItemIds = newExtraItemIds;
        save(res);
    }

    function toJson()
    {
        console.log(JSON.stringify(JSON.parse(localStorage.getItem("pm_data")).items));
    }

    function toLua()
    {
        const res = load();
        const resItems = res.items || [];

        const lines = [];

        lines.push("{");

        for (let i = 0; i < resItems.length; i++)
        {
            const item = resItems[i];

            if (!item.itemId && !item.iconId && !item.spellId && !item.name)
            {
                continue;
            }

            lines.push("\t[" + item.itemId + "] = {");
            lines.push("\t\tspellId = " + (item.spellId || "nil") + ",");
            lines.push("\t\tname = " + (item.name ? "\"" + item.name + "\"" : "nil") + ",");
            lines.push("\t\tcount = " + (item.count ? "\"" + item.count + "\"" : "nil") + ",");
            lines.push("\t\ttype = " + (item.type ? "\"" + item.type + "\"" : "nil") + ",");

            lines.push("\t\tlvl = {");

            lines.push("\t\t\treq = " + item.lvl.req + ",");

            if (item.lvl.r1)
            {
                lines.push("\t\t\tr1= " + item.lvl.r1 + ",");
            }
            if (item.lvl.r2)
            {
                lines.push("\t\t\tr2= " + item.lvl.r2 + ",");
            }
            if (item.lvl.r3)
            {
                lines.push("\t\t\tr3= " + item.lvl.r3 + ",");
            }
            if (item.lvl.r4)
            {
                lines.push("\t\t\tr4= " + item.lvl.r4 + ",");
            }

            lines.push("\t\t},");

            if (item.mats)
            {
                lines.push("\t\tmats = {");

                for (let j = 0; j < item.mats.length; j++)
                {
                    const mat = item.mats[j];

                    lines.push("\t\t\t[" + mat.itemId + "] = " + mat.count + ",");
                }

                lines.push("\t\t},");
            }

            lines.push("\t},");
        }

        lines.push("}");

        console.log(lines.join("\n"));
    }

    window.whe = {
        load,
        save,
        clear,
        getWh: getWowheadListItems,
        normalize,
        toLua,
        toJson,
    };

    console.log("DATA:", load());
})();