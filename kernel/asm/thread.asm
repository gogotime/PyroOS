[bits 32]
section .text
global switchTo
switchTo:
    push esi
    push edi
    push ebx
    push ebp
    mov eax,[esp+20]
    mov [eax],esp

    mov eax,[esp+24]
    mov esp,[eax]

    pop ebp
    pop ebx
    pop edi
    pop esi
    ret
