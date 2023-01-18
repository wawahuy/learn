export function FReverce(target: any, key: string, description: PropertyDescriptor) {
    const original = description.value;
    description.value = function () {
        return original.apply(this).split('').reverse().join('');
    }
}