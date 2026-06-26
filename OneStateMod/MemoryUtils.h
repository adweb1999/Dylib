#pragma once
#include <mach/mach.h>
#include <sys/types.h>
#include <substrate.h>

namespace MemoryUtils {
    template<typename T>
    T ReadMemory(uint64_t address) {
        T value = {};
        vm_size_t size = sizeof(T);
        vm_read_overwrite(mach_task_self(), address, sizeof(T), 
                          (vm_address_t)&value, &size);
        return value;
    }

    template<typename T>
    void WriteMemory(uint64_t address, T value) {
        vm_write(mach_task_self(), address, (vm_offset_t)&value, sizeof(T));
    }

    uint64_t FindPattern(const char* pattern, const char* mask, 
                         uint64_t start, uint64_t size);
    uint64_t GetModuleBase(const char* moduleName);
    uint64_t GetModuleSize(const char* moduleName);
    bool ProtectMemory(uint64_t address, size_t size, int protection);
    bool PatchBytes(uint64_t address, const char* bytes, size_t size);
    bool NopInstructions(uint64_t address, size_t count);
}
