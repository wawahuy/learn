import assert from 'node:assert';
import process from 'node:process';

// Creates call tracker.
const tracker = new assert.CallTracker();

function func() {
    assert.deepEqual(1, 1);
}

// Returns a function that wraps func() that must be called exact times
// before tracker.verify().
const callsfunc = tracker.calls(func, 1);

// Returns an array containing information on callsfunc()
console.log(tracker.report());


process.on('exit', () => {
    tracker.verify();
})