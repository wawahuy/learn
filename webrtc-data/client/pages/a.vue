<template>
    <div>wtf {{ isOpen  }}</div>
</template>

<script setup lang="ts">
import { io } from "socket.io-client";

const nameMe = 'a';
const isOpen = useState('isOpen', () => false);

const socket = io("ws://localhost:8080");
socket.on('connect', () => {
    isOpen.value = true;
    socket.emit('name', nameMe);
})

</script>