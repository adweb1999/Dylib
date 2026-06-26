#include "MemoryUtils.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <substrate.h>
#include <cstring>

namespace MemoryUtils {
    uint64_t FindPattern(const char* pattern, const char* mask, 
                         uint64_t start, uint64_t size) {
        size_t patternLength = strlen(mask);
        for (uint64_t i = 0; i < size - patternLength; i++) {
            bool found = true;
            for (size_t j = 0; j < patternLength; j++) {
                if (mask[j] == 'x' && ((char*)start)[i + j] != pattern[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return start + i;
        }
        return 0;
    }

    uint64_t GetModuleBase(const char* moduleName) {
        uint32_t count = _dyld_image_count();
        for (uint32_t i = 0; i < count; i++) {
            const char* name = _dyld_get_image_name(i);
            if (strstr(name, moduleName)) {
                return (uint64_t)_dyld_get_image_header(i);
            }
        }
        return 0;
    }

    uint64_t GetModuleSize(const char* moduleName) {
        uint64_t base = GetModuleBase(moduleName);
        if (!base) return 0;
        return 0x1000000;
    }

    bool ProtectMemory(uint64_t address, size_t size, int protection) {
        kern_return_t result = vm_protect(mach_task_self(), address, size, 
                                          false, protection);
        return result == KERN_SUCCESS;
    }

    bool PatchBytes(uint64_t address, const char* bytes, size_t size) {
        if (!ProtectMemory(address, size, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY)) {
            return false;
        }
        memcpy((void*)address, bytes, size);
        ProtectMemory(address, size, VM_PROT_READ | VM_PROT_EXECUTE);
        return true;
    }

    bool NopInstructions(uint64_t address, size_t count) {
        char* nops = new char[count];
        memset(nops, 0xD5, count);
        bool result = PatchBytes(address, nops, count);
        delete[] nops;
        return result;
    }
}
