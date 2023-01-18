export function PTimeAgo(target: any, key: string) {
    let _val = target[key] || Date.now();
    Object.defineProperty(target, key, {
        get: function () {
            const df = Date.now() - _val;
            return `${_val} (${df}ms ago)`
        },
        set: function (val) {
            _val = val;
        }
    })
}