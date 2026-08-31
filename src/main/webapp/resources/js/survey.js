(function (window) {
    "use strict";

    var SM = {};

    /* ---------------- helpers ---------------- */

    SM.escapeHtml = function (text) {
        return String(text == null ? "" : text)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;")
            .replace(/'/g, "&#39;");
    };

    SM.request = function (method, url, data) {
        var opts = { method: method, headers: {} };
        if (data !== undefined) {
            opts.headers["Content-Type"] = "application/json";
            opts.body = JSON.stringify(data);
        }
        return fetch(url, opts).then(function (resp) {
            return resp.json();
        });
    };

    SM.get = function (url) { return SM.request("GET", url); };
    SM.post = function (url, data) { return SM.request("POST", url, data || {}); };

    /* ---------------- modals / toast ---------------- */

    SM.openModal = function (id) {
        document.getElementById(id).classList.add("open");
        document.getElementById("sm-backdrop").classList.add("open");
    };

    SM.closeModals = function () {
        Array.prototype.forEach.call(document.querySelectorAll(".sm-modal"), function (m) {
            m.classList.remove("open");
        });
        document.getElementById("sm-backdrop").classList.remove("open");
    };

    SM.confirm = function (title, messageHtml, onConfirm) {
        document.getElementById("sm-confirm-title").textContent = title;
        document.getElementById("sm-confirm-message").innerHTML = messageHtml;
        var ok = document.getElementById("sm-confirm-ok");
        ok.onclick = function () { SM.closeModals(); onConfirm(); };
        SM.openModal("sm-modal-confirm");
    };

    var toastTimer = null;
    SM.toast = function (message, isError) {
        var el = document.getElementById("sm-toast");
        el.textContent = message;
        el.classList.toggle("error", !!isError);
        el.classList.toggle("success", !isError);
        el.classList.add("show");
        if (toastTimer) { window.clearTimeout(toastTimer); }
        toastTimer = window.setTimeout(function () { el.classList.remove("show"); }, 3500);
    };

    /* ---------------- config model ---------------- */

    var TYPE_LABELS = {
        string: "Text", textarea: "Paragraph", int: "Number", select1: "Select", select: "Multiple Select",
        radio: "Radio", checkbox: "Checkbox", binary: "Media", date: "Date", time: "Time",
        section: "Section Header", calc: "Calculated"
    };
    var TYPE_PREFIX = {
        string: "text_", textarea: "para_", int: "num_", select1: "select_", select: "mselect_",
        radio: "radio_", checkbox: "chk_", binary: "media_", date: "date_", time: "time_",
        section: "section_", calc: "calc_"
    };

    SM.typeLabel = function (t) { return TYPE_LABELS[t] || t; };
    SM.typePrefix = function (t) { return TYPE_PREFIX[t] || "field_"; };

    // parse a sources field (csv string or array) into a list of qnames
    SM.parseSources = function (s) {
        if (Array.isArray(s)) {
            return s.map(function (x) { return String(x).trim(); }).filter(function (x) { return x !== ""; });
        }
        if (typeof s === "string") {
            return s.split(",").map(function (x) { return x.trim(); }).filter(function (x) { return x !== ""; });
        }
        return [];
    };
    SM.hasOptions = function (t) { return t === "select1" || t === "select" || t === "radio" || t === "checkbox"; };

    // config JSON (question1..N keyed object) -> ordered array of normalized questions
    SM.parseConfig = function (confData) {
        var data = {};
        try {
            data = typeof confData === "string" ? JSON.parse(confData) : (confData || {});
        } catch (e) {
            console.error("Invalid questionnaire config", e);
        }

        return Object.keys(data)
            .sort(function (a, b) {
                var na = parseInt((String(a).match(/\d+/) || ["0"])[0], 10);
                var nb = parseInt((String(b).match(/\d+/) || ["0"])[0], 10);
                return na - nb;
            })
            .map(function (key, idx) {
                var q = data[key];
                var norm = {
                    qtype: q.qtype || "string",
                    caption: q.caption || "",
                    hint: q.hint || "",
                    qname: q.qname || ("question_" + (idx + 1)),
                    required: !!q.required,
                    hidden: !!q.hidden,
                    readonly: !!q.readonly,
                    savable: q.savable !== false,
                    options: Array.isArray(q.options) ? q.options : [],
                    mediaType: q.mediaType || "",
                    pos: (q.pos && typeof q.pos.top === "number" && typeof q.pos.left === "number")
                        ? { top: q.pos.top, left: q.pos.left }
                        : null
                };
                ["placeholder", "pattern", "minlength", "maxlength", "min", "max", "step", "value", "title"].forEach(function (k) {
                    if (q[k] !== undefined && q[k] !== null && String(q[k]) !== "") {
                        norm[k] = String(q[k]);
                    }
                });
                norm.visibleIf = (function (v) {
                    if (!v || v.target === undefined || v.target === "") { return null; }
                    var value = String(v.value == null ? "" : v.value);
                    var op = v.op || (value.trim() === "" ? "notEmpty" : "in");
                    return { target: String(v.target), op: op, value: value };
                })(q.visibleIf);
                norm.jump = (function (j) {
                    if (!j) { return null; }
                    var branches = [];
                    if (Array.isArray(j.branches) && j.branches.length) {
                        j.branches.forEach(function (br) {
                            if (!br || br.target === undefined || br.target === "" || br.target == null) { return; }
                            var v = (typeof br.value === "string") ? br.value : (br.value == null ? "" : String(br.value));
                            var op = br.op || (v.trim() === "" ? "notEmpty" : "in");
                            branches.push({ target: String(br.target), op: op, value: v });
                        });
                    } else if (j.target !== undefined && j.target !== "" && j.target != null) {
                        // legacy single if/else shape
                        var vv = (typeof j.value === "string") ? j.value : (j.value == null ? "" : String(j.value));
                        var op2 = j.op || (vv.trim() === "" ? "notEmpty" : "in");
                        branches.push({ target: String(j.target), op: op2, value: vv });
                    }
                    if (!branches.length) { return null; }
                    var elseTarget = (j.elseTarget != null && j.elseTarget !== "") ? String(j.elseTarget) : null;
                    return { branches: branches, elseTarget: elseTarget };
                })(q.jump);
                var nsRaw = q.nextStep;
                norm.nextStep = (nsRaw === -1 || String(nsRaw) === "-1") ? -1
                    : (nsRaw != null && String(nsRaw) !== "" && !isNaN(parseInt(nsRaw, 10)))
                        ? parseInt(nsRaw, 10) : null;
                norm.errMsg = (q.errMsg && String(q.errMsg).trim() !== "") ? String(q.errMsg) : "";

                if (norm.qtype === "section") {
                    norm.required = false;
                    norm.readonly = false;
                    norm.savable = false;
                    norm.options = [];
                } else if (norm.qtype === "calc") {
                    norm.required = false;
                    norm.readonly = true;
                    norm.savable = true;
                    norm.op = q.op || "sum";
                    norm.unit = q.unit || "";
                    norm.sources = SM.parseSources(q.sources);
                }
                return norm;
            });
    };

    SM.buildConfig = function (questions) {
        var out = {};
        questions.forEach(function (q, i) {
            out["question" + (i + 1)] = q;
        });
        return out;
    };

    // Improved naming: unique, type-aware variable names
    SM.uniqueName = function (questions, type) {
        var base = SM.typePrefix(type);
        var max = 0;
        questions.forEach(function (q) {
            var m = String(q.qname || "").match(new RegExp("^" + base + "(\\d+)$"));
            if (m) { max = Math.max(max, parseInt(m[1], 10)); }
        });
        return base + (max + 1);
    };

    SM.duplicateNames = function (questions) {
        var seen = {}, dups = [];
        questions.forEach(function (q) {
            var n = (q.qname || "").trim();
            if (!n) { return; }
            if (seen[n] && dups.indexOf(n) === -1) { dups.push(n); }
            seen[n] = true;
        });
        return dups;
    };

    // Returns -1 when valid, otherwise the index of the first invalid question
    SM.validateQuestions = function (questions) {
        for (var i = 0; i < questions.length; i++) {
            var q = questions[i];
            if (q.hidden) {
                // hidden fields are never rendered/validated, but still need a unique variable name
                if (!q.qname.trim()) { return i; }
                continue;
            }
            if (!q.caption.trim()) { return i; }
            if (!q.qname.trim()) { return i; }
            if (SM.hasOptions(q.qtype)) {
                if (!q.options.length) { return i; }
                for (var j = 0; j < q.options.length; j++) {
                    if (!String(q.options[j].value).trim()) { return i; }
                }
            }
            if (q.visibleIf) {
                if (q.visibleIf.target === "" || isNaN(parseInt(q.visibleIf.target, 10))) { return i; }
                if (parseInt(q.visibleIf.target, 10) >= i) { return i; }
            }
            if (q.jump) {
                var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                for (var k = 0; k < brs.length; k++) {
                    var jt = parseInt(brs[k].target, 10);
                    if (isNaN(jt)) { return i; }
                    if (jt === i || jt < 0 || jt >= questions.length) { return i; }
                }
                if (q.jump.elseTarget != null) {
                    var jet = parseInt(q.jump.elseTarget, 10);
                    if (isNaN(jet) || jet === i || jet < 0 || jet >= questions.length) { return i; }
                }
            }
        }
        return -1;
    };

    /* ---------------- conditional operators ---------------- */

    SM.opsForType = function (t) {
        if (SM.hasOptions(t)) {
            return [
                { v: "in", l: "is one of" },
                { v: "nin", l: "is none of" },
                { v: "notEmpty", l: "has any answer" }
            ];
        }
        switch (t) {
            case "int":
                return [
                    { v: "eq", l: "equals" },
                    { v: "neq", l: "not equals" },
                    { v: "gt", l: "greater than" },
                    { v: "gte", l: "greater or equal" },
                    { v: "lt", l: "less than" },
                    { v: "lte", l: "less or equal" },
                    { v: "notEmpty", l: "has any answer" }
                ];
            case "date":
            case "time":
                return [
                    { v: "eq", l: "on / at" },
                    { v: "neq", l: "not on / at" },
                    { v: "before", l: "before" },
                    { v: "after", l: "after" },
                    { v: "lte", l: "on/before" },
                    { v: "gte", l: "on/after" },
                    { v: "notEmpty", l: "has any answer" }
                ];
            case "binary":
                return [{ v: "notEmpty", l: "has a file" }];
            default:
                return [
                    { v: "eq", l: "equals" },
                    { v: "neq", l: "not equals" },
                    { v: "contains", l: "contains" },
                    { v: "notContains", l: "does not contain" },
                    { v: "startsWith", l: "starts with" },
                    { v: "endsWith", l: "ends with" },
                    { v: "notEmpty", l: "has any answer" }
                ];
        }
    };

    SM.opLabel = function (t, op) {
        var ops = SM.opsForType(t);
        for (var i = 0; i < ops.length; i++) {
            if (ops[i].v === op) { return ops[i].l; }
        }
        return op;
    };

    function cmpVals(a, b) {
        var na = parseFloat(a), nb = parseFloat(b);
        if (!isNaN(na) && !isNaN(nb) && String(a).trim() !== "" && String(b).trim() !== "") {
            return na < nb ? -1 : na > nb ? 1 : 0;
        }
        return String(a) < String(b) ? -1 : String(a) > String(b) ? 1 : 0;
    }

    function evalCondition(op, val, rawWanted) {
        var wanted = String(rawWanted == null ? "" : rawWanted)
            .split(",").map(function (s) { return s.trim(); })
            .filter(function (s) { return s !== ""; });
        var sel = val.split(",").map(function (s) { return s.trim(); })
            .filter(function (s) { return s !== ""; });

        function anyMatch() {
            return sel.some(function (v) { return wanted.indexOf(v) !== -1; });
        }

        switch (op) {
            case "notEmpty": return val !== "";
            case "eq": return val !== "" && anyMatch();
            case "neq": return val !== "" && !anyMatch();
            case "in": return anyMatch();
            case "nin": return val !== "" && !anyMatch();
            case "contains":
                return wanted.some(function (w) {
                    return w !== "" && val.toLowerCase().indexOf(w.toLowerCase()) !== -1;
                });
            case "notContains":
                return val !== "" && !evalCondition("contains", val, rawWanted);
            case "startsWith":
                return val !== "" && wanted.some(function (w) {
                    w = w.toLowerCase();
                    return w !== "" && val.toLowerCase().lastIndexOf(w, 0) === 0;
                });
            case "endsWith":
                return val !== "" && wanted.some(function (w) {
                    var lv = val.toLowerCase(), lw = w.toLowerCase();
                    return lw !== "" && lv.lastIndexOf(lw) === lv.length - lw.length;
                });
            case "gt": case "after":
                return val !== "" && cmpVals(val, wanted[0]) > 0;
            case "gte": return val !== "" && cmpVals(val, wanted[0]) >= 0;
            case "lt": case "before":
                return val !== "" && cmpVals(val, wanted[0]) < 0;
            case "lte": return val !== "" && cmpVals(val, wanted[0]) <= 0;
            default:
                return anyMatch();
        }
    }

    /* ---------------- form rendering engine ---------------- */

    function findGroup(groups, target) {
        var t = String(target == null ? "" : target).trim();
        if (/^\d+$/.test(t)) {
            var k = parseInt(t, 10);
            return groups[k] || null;
        }
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].input.name === t) { return groups[i]; }
        }
        return null;
    }

    function inputValue(input) {
        if (!input) { return ""; }
        if (input.type === "file") { return input.files.length ? input.files[0].name : ""; }
        if (input.tagName === "FIELDSET") {
            return Array.prototype.filter.call(
                input.querySelectorAll("input[type=radio],input[type=checkbox]"),
                function (el) { return el.checked; }
            ).map(function (el) { return el.value; }).join(",");
        }
        if (input.multiple) {
            return Array.prototype.filter.call(input.options, function (o) { return o.selected; })
                .map(function (o) { return o.value; }).join(",");
        }
        return input.value;
    }

    function isVisible(q, groups) {
        if (!q.visibleIf) { return true; }
        var g = findGroup(groups, q.visibleIf.target);
        if (!g) { return true; }
        var val = inputValue(g.input);
        return evalCondition(q.visibleIf.op || "in", val, q.visibleIf.value);
    }

    // Renders a live form into containerEl (vanilla DOM). forTest=true wires validation + submit summary.
    SM.renderForm = function (questions, containerEl, forTest) {
        var form = document.createElement("form");
        form.className = "sm-form row g-3";
        form.noValidate = true;

        var groups = [];
        var progBar = null, progText = null;
        var byQname = {};

        questions.forEach(function (q, i) {
            var id = "smf_" + i;
            var group = document.createElement("div");
            group.className = "col-12";
            group.dataset.idx = String(i);

            var input;

            if (q.qtype === "section") {
                var sec = document.createElement("div");
                sec.className = "sm-section-head";
                var shd = document.createElement("h4");
                shd.className = "sm-section-title";
                shd.textContent = q.caption || ("Section " + (i + 1));
                sec.appendChild(shd);
                if (q.hint) {
                    var shint = document.createElement("div");
                    shint.className = "form-text";
                    shint.textContent = q.hint;
                    sec.appendChild(shint);
                }
                group.appendChild(sec);
                form.appendChild(group);
                groups.push({ q: q, group: group, input: group, isSection: true });
                return;
            }

            if (q.qtype === "calc") {
                var clbl = document.createElement("label");
                clbl.className = "form-label fw-semibold";
                clbl.innerHTML = SM.escapeHtml(q.caption);
                group.appendChild(clbl);
                var cwrap = document.createElement("div");
                var cin = document.createElement("input");
                cin.type = "text";
                cin.className = "form-control";
                cin.readOnly = true;
                cin.id = id;
                cin.name = q.qname || ("question_" + (i + 1));
                cin.value = "";
                cwrap.appendChild(cin);
                if (q.hint) {
                    var chint = document.createElement("div");
                    chint.className = "form-text";
                    chint.textContent = q.hint;
                    cwrap.appendChild(chint);
                }
                group.appendChild(cwrap);
                form.appendChild(group);
                groups.push({ q: q, group: group, input: cin, isCalc: true });
                return;
            }


            if (q.hidden) {
                // invisible placeholder keeps question indexes stable for jumps/conditions,
                // but still carries id/name and any configured HTML attributes
                input = document.createElement("input");
                input.type = "hidden";
                input.id = id;
                input.name = q.qname || ("question_" + (i + 1));
                ["placeholder", "pattern", "minlength", "maxlength", "min", "max", "step", "title"].forEach(function (k) {
                    if (q[k] !== undefined && q[k] !== null && String(q[k]) !== "") {
                        input.setAttribute(k, q[k]);
                    }
                });
            if (q.value !== undefined && q.value !== null && String(q.value) !== "") {
                input.value = q.value;
            }

            // readonly works for every field type
            if (q.readonly) {
                if (input.tagName === "SELECT") {
                    // selects have no native readonly: lock all options except the selected one,
                    // so the current value is kept and still submitted
                    Array.prototype.forEach.call(input.options, function (o) { o.disabled = !o.selected; });
                } else if (q.qtype !== "binary") {
                    input.readOnly = true;
                }
            }
                group.appendChild(input);                group.style.display = "none";
                form.appendChild(group);
                groups.push({ q: q, group: group, input: input });
                return;
            }

            var label = document.createElement("label");
            label.className = "form-label fw-semibold";
            label.htmlFor = id;
            label.innerHTML = SM.escapeHtml(q.caption) + (q.required ? '<span class="req-star">*</span>' : "");
            group.appendChild(label);

            if (q.hint) {
                var hint = document.createElement("div");
                hint.className = "form-text sm-field-hint";
                hint.textContent = q.hint;
                group.appendChild(hint);
            }

            var wrap = document.createElement("div");
            var input;

            switch (q.qtype) {
                case "int":
                    input = document.createElement("input");
                    input.type = "number";
                    input.step = "any";
                    input.className = "form-control";
                    break;
                case "date":
                    input = document.createElement("input");
                    input.type = "date";
                    input.className = "form-control";
                    break;
                case "time":
                    input = document.createElement("input");
                    input.type = "time";
                    input.className = "form-control";
                    break;
                case "binary":
                    input = document.createElement("input");
                    input.type = "file";
                    input.className = "form-control";
                    if (q.mediaType) { input.accept = q.mediaType; }
                    break;
                case "textarea":
                    input = document.createElement("textarea");
                    input.className = "form-control";
                    break;
                case "select1":
                    input = document.createElement("select");
                    input.className = "form-select";
                    input.appendChild(new Option("-- Select --", ""));
                    q.options.forEach(function (opt) {
                        input.appendChild(new Option(opt.caption, opt.value));
                    });
                    break;
                case "select":
                    input = document.createElement("select");
                    input.className = "form-select";
                    input.multiple = true;
                    input.size = Math.min(Math.max(q.options.length, 2), 6);
                    q.options.forEach(function (opt) {
                        input.appendChild(new Option(opt.caption, opt.value));
                    });
                    break;
                case "radio":
                case "checkbox":
                    var fieldset = document.createElement("fieldset");
                    fieldset.className = "mt-1";
                    q.options.forEach(function (opt, oi) {
                        var wrap = document.createElement("div");
                        wrap.className = "form-check";
                        var inp = document.createElement("input");
                        inp.type = q.qtype === "radio" ? "radio" : "checkbox";
                        inp.className = "form-check-input";
                        inp.name = q.qname || ("question_" + (i + 1));
                        inp.value = opt.value;
                        inp.id = id + "_" + oi;
                        var lbl = document.createElement("label");
                        lbl.className = "form-check-label";
                        lbl.setAttribute("for", id + "_" + oi);
                        lbl.textContent = opt.caption;
                        wrap.appendChild(inp);
                        wrap.appendChild(lbl);
                        fieldset.appendChild(wrap);
                    });
                    input = fieldset;
                    break;
                default:
                    input = document.createElement("input");
                    input.type = "text";
                    input.className = "form-control";
            }

            if (q.qtype === "textarea") {
                input.rows = 3;
            }

            // HTML validation attributes (per-field properties)
            ["placeholder", "pattern", "minlength", "maxlength", "min", "max", "step", "title"].forEach(function (k) {
                if (q[k] !== undefined && q[k] !== null && String(q[k]) !== "") {
                    input.setAttribute(k, q[k]);
                }
            });
            if (q.value !== undefined && q.value !== null && String(q.value) !== "") {
                input.value = q.value;
            }
            if (q.value !== undefined && q.value !== null && String(q.value) !== "") {
                input.value = q.value;
            }

            input.id = id;
            input.name = q.qname || ("question_" + (i + 1));
            group.appendChild(input);

            var invalid = document.createElement("div");
            invalid.className = "invalid-feedback d-none";
            invalid.textContent = q.errMsg || "This field is required.";
            group.appendChild(invalid);

            form.appendChild(group);
            groups.push({ q: q, group: group, input: input });
        });

        groups.forEach(function (g) {
            var nm = g.q.qname || g.input.name;
            if (nm) { byQname[nm] = g; }
        });

        function reevaluate() {
            // sequential walk: forward jumps skip intermediate questions, backward jumps
            // rewind the flow to the target (with a cycle guard against ping-pong loops)
            var skipUntil = -1;
            var backtracks = 0;
            var i = 0;
            while (i < groups.length) {
                var g = groups[i];
                var vis = !g.q.hidden && (skipUntil === -1 || i >= skipUntil);
                if (vis) { vis = isVisible(g.q, groups); }
                if (g.isSection) {
                    // a section heading is a persistent visual divider: never hidden by
                    // branching skips (jump / nextStep) so the form structure stays intact
                    vis = !g.q.hidden && isVisible(g.q, groups);
                }

                if (vis && g.q.jump && backtracks < 25) {
                    // if / else if / else: evaluate branches top-down, first match wins
                    var branches = g.q.jump.branches || [];
                    var matched = false;
                    var target = null;
                    for (var b = 0; b < branches.length; b++) {
                        var br = branches[b];
                        if (evalCondition(br.op || "notEmpty", inputValue(g.input), br.value)) {
                            matched = true;
                            target = parseInt(br.target, 10);
                            break;
                        }
                    }
                    if (!matched && g.q.jump.elseTarget != null) {
                        target = parseInt(g.q.jump.elseTarget, 10);
                    }
                    if (target != null && !isNaN(target)) {
                        if (target > i) {
                            skipUntil = target;
                        } else if (target < i) {
                            backtracks++;
                            skipUntil = -1;
                            i = target;
                            continue;
                        }
                    } else if (!matched && g.q.nextStep != null && g.q.nextStep !== -1) {
                        var ns = parseInt(g.q.nextStep, 10);
                        if (!isNaN(ns)) {
                            if (ns > i) {
                                skipUntil = ns;
                            } else if (ns < i) {
                                backtracks++;
                                skipUntil = -1;
                                i = ns;
                                continue;
                            }
                        }
                    }
                } else if (vis && g.q.nextStep != null && g.q.nextStep !== -1 && backtracks < 25) {
                    var ns2 = parseInt(g.q.nextStep, 10);
                    if (!isNaN(ns2)) {
                        if (ns2 > i) {
                            skipUntil = ns2;
                        } else if (ns2 < i) {
                            backtracks++;
                            skipUntil = -1;
                            i = ns2;
                            continue;
                        }
                    }
                }
                g.group.style.display = vis ? "" : "none";
                i++;
            }

            // recompute calculated/score fields from their current source values
            groups.forEach(function (g) {
                if (!g.isCalc || g.group.style.display === "none") { return; }
                var vals = [];
                (g.q.sources || []).forEach(function (src) {
                    var sg = byQname[src];
                    if (sg) {
                        var num = parseFloat(inputValue(sg.input));
                        if (!isNaN(num)) { vals.push(num); }
                    }
                });
                var result = "";
                if (vals.length) {
                    var op = g.q.op || "sum";
                    var r;
                    if (op === "avg") { r = vals.reduce(function (a, b) { return a + b; }, 0) / vals.length; }
                    else if (op === "count") { r = vals.length; }
                    else if (op === "min") { r = Math.min.apply(null, vals); }
                    else if (op === "max") { r = Math.max.apply(null, vals); }
                    else { r = vals.reduce(function (a, b) { return a + b; }, 0); }
                    result = g.q.unit ? (r + " " + g.q.unit) : String(r);
                }
                g.input.value = result;
            });

            updateProgress();
        }

        function updateProgress() {
            if (!progBar) { return; }
            var total = 0, done = 0;
            groups.forEach(function (g) {
                if (g.q.hidden || g.q.qtype === "section" || g.q.qtype === "calc") { return; }
                if (g.group.style.display === "none") { return; }
                total++;
                if (inputValue(g.input) !== "") { done++; }
            });
            if (total === 0) { progBar.style.width = "0%"; progText.textContent = ""; return; }
            var pct = Math.round((done / total) * 100);
            progBar.style.width = pct + "%";
            progText.textContent = "Answered " + done + " of " + total;
        }

        groups.forEach(function (g) {
            ["change", "input"].forEach(function (evt) {
                g.input.addEventListener(evt, reevaluate);
            });
        });
        reevaluate();

        if (forTest) {
            var progress = document.createElement("div");
            progress.className = "col-12 mb-2";
            var pbarWrap = document.createElement("div");
            pbarWrap.className = "progress";
            pbarWrap.style.height = "6px";
            progBar = document.createElement("div");
            progBar.className = "progress-bar bg-success";
            progBar.style.width = "0%";
            pbarWrap.appendChild(progBar);
            progText = document.createElement("small");
            progText.className = "text-muted";
            progress.appendChild(pbarWrap);
            progress.appendChild(progText);
            form.insertBefore(progress, form.firstChild);

            var actions = document.createElement("div");
            actions.className = "col-12 mt-4";
            actions.innerHTML =
                '<button type="submit" class="btn btn-primary me-2">Submit Test</button>' +
                '<button type="reset" class="btn btn-outline-secondary">Reset</button>';
            form.appendChild(actions);

            form.addEventListener("submit", function (e) {
                e.preventDefault();
                var ok = true;
                var values = {};
                groups.forEach(function (g) {
                    if (g.group.style.display === "none") { return; }
                    if (g.q.qtype === "section" || g.q.qtype === "calc") { return; }
                    var v = inputValue(g.input);
                    if (g.q.required && !v) {
                        ok = false;
                        g.input.classList.add("is-invalid");
                        g.input.addEventListener("input", function h() {
                            g.input.classList.remove("is-invalid");
                            g.input.removeEventListener("input", h);
                        });
                    } else {
                        g.input.classList.remove("is-invalid");
                        if (v !== "" && g.q.savable !== false) {
                            values[g.q.qname || g.input.name || ("question_" + (i + 1))] = v;
                        }
                    }
                });
                if (!ok) {
                    SM.toast("Please fill in all required visible fields.", true);
                    return;
                }
                SM.toast("Form valid. Captured data: " + JSON.stringify(values));
            });

            form.addEventListener("reset", function () {
                window.setTimeout(reevaluate, 0);
            });
        }

        containerEl.innerHTML = "";
        containerEl.appendChild(form);
        return form;
    };

    /* ---------------- shared chrome injection ---------------- */

    window.addEventListener("DOMContentLoaded", function () {
        var chrome = document.createElement("div");
        chrome.innerHTML =
            '<div id="sm-backdrop" class="sm-modal-backdrop"></div>' +
            '<div class="sm-modal" id="sm-modal-test">' +
            '<div class="sm-modal-head"><h5>Form Test</h5><button type="button" class="btn-close sm-modal-close"></button></div>' +
            '<div class="sm-modal-body"><div id="sm-test-form-holder"></div></div>' +
            "</div>" +
            '<div class="sm-modal" id="sm-modal-confirm">' +
            '<div class="sm-modal-head"><h5 id="sm-confirm-title">Confirm</h5><button type="button" class="btn-close sm-modal-close"></button></div>' +
            '<div class="sm-modal-body"><p id="sm-confirm-message"></p></div>' +
            '<div class="sm-modal-foot">' +
            '<button type="button" class="btn btn-outline-secondary sm-modal-close">Cancel</button>' +
            '<button type="button" class="btn btn-danger" id="sm-confirm-ok">OK</button>' +
            "</div>" +
            "</div>" +
            '<div id="sm-toast" class="sm-alert"></div>';
        while (chrome.firstChild) { document.body.appendChild(chrome.firstChild); }

        document.addEventListener("click", function (e) {
            if (e.target.closest(".sm-modal-close") || e.target.id === "sm-backdrop") { SM.closeModals(); }
        });
        document.addEventListener("keyup", function (e) {
            if (e.key === "Escape") { SM.closeModals(); }
        });
    });

    window.SM = SM;

})(window);
