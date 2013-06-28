/**
 * Global Abatement
 */

var MAIN = MAIN || {};

MAIN.namespace = function (aNamespace)
{
    var parts = aNamespace.split('.'),
        parent = MAIN,
        i;
    if (parts[0] === "MAIN") {
        parts = parts.slice(1);
    }

    for (i = 0; i < parts.length; i += 1) {
        if (typeof parent[parts[i]] === "undefined") {
            parent[parts[i]] = {};
        }
        parent = parent[parts[i]];
    }

    return parent;
};