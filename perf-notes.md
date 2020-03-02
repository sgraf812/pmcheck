# Perf notes

All test cases were compiled using:

```
-fforce-recomp -ddump-timings -Wincomplete-patterns -Woverlapping-patterns -Wincomplete-uni-patterns -Wincomplete-record-updates
```

## GHC 8.8.3

| Test case   | Time (desugar) | Bytes allocated (desugar) |
| ----------- | -------------- | ------------------------- |
| `T11276`    | ??             | ??                        |
| `T11303`    | ??             | ??                        |
| `T11303b`   | ??             | ??                        |
| `T11374`    | ??             | ??                        |
| `T11822`    | ??             | ??                        |
| `T11195`    | ??             | ??                        |
| `T17096`    | ??             | ??                        |
| `PmSeriesS` | ??             | ??                        |
| `PmSeriesT` | ??             | ??                        |
| `PmSeriesV` | ??             | ??                        |
| `PmSeriesG` | ??             | ??                        |

## GHC HEAD

| Test case   | Time (desugar) | Bytes allocated (desugar) |
| ----------- | -------------- | ------------------------- |
| `T11276`    | ??             | ??                        |
| `T11303`    | ??             | ??                        |
| `T11303b`   | ??             | ??                        |
| `T11374`    | ??             | ??                        |
| `T11822`    | ??             | ??                        |
| `T11195`    | ??             | ??                        |
| `T17096`    | ??             | ??                        |
| `PmSeriesS` | ??             | ??                        |
| `PmSeriesT` | ??             | ??                        |
| `PmSeriesV` | ??             | ??                        |
| `PmSeriesG` | ??             | ??                        |
