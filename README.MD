Своя реализацию ps ax через анализ `/proc`
- Результат ДЗ - рабочий скрипт `ps-ax.sh`, который можно запустить.


Алгоритм статусов BSD-Style был взят из исходных кодов ps из файла output.c
По ссылке https://gitlab.com/procps-ng/procps/blob/master/ps/output.c#L585

```php
static int pr_stat(char *restrict const outbuf, const proc_t *restrict const pp){
    int end = 0;
    outbuf[end++] = pp->state;
//  if(pp->rss==0 && pp->state!='Z')  outbuf[end++] = 'W'; // useless "swapped out"
    if(pp->nice < 0)                  outbuf[end++] = '<';
    if(pp->nice > 0)                  outbuf[end++] = 'N';
// In this order, NetBSD would add:
//     traced   'X'
//     systrace 'x'
//     exiting  'E' (not printed for zombies)
//     vforked  'V'
//     system   'K' (and do not print 'L' too)
    if(pp->vm_lock)                   outbuf[end++] = 'L';
    if(pp->session == pp->tgid)       outbuf[end++] = 's'; // session leader
    if(pp->nlwp > 1)                  outbuf[end++] = 'l'; // multi-threaded
    if(pp->pgrp == pp->tpgid)         outbuf[end++] = '+'; // in foreground process group
    outbuf[end] = '\0';
    return end;
}
```
