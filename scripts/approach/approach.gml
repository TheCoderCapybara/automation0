function approach(current, target, amount) {
    if (current < target) return min(current + amount, target);
    if (current > target) return max(current - amount, target);
    return current;
}