export function FLogger(target: any, key: string, description: PropertyDescriptor) {
    console.log(target, key);
    const original = description.value;
    description.value = function (...args: any[]) {
        console.log('FLogger before handle');
        const result = original.apply(this, args);
        console.log('FLogger result:', result);
        return result;
    }
}