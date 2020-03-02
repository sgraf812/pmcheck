# Perf notes

All test cases were compiled using:

```
<ghc> <Test case> -fforce-recomp -ddump-timings -Wincomplete-patterns -Woverlapping-patterns -Wincomplete-uni-patterns -Wincomplete-record-updates | grep "Desugar"
```

## GHC 8.8.3

| Test case   | Time (desugar) | Bytes allocated (desugar) |
| ----------- | -------------- | ------------------------- |
| `T11276`    | 1.159          | 1856464                   |
| `T11303`    | 28.056         | 60189288                  |
| `T11303b`   | 1.147          | 1649528                   |
| `T11374`    | 4.623          | 6159712                   |
| `T11822`    | 1063.495       | 2006687040                |
| `T11195`    | 2677.682       | 3084609976                |
| `T17096`    | 7469.693       | 17251358480               |
| `PmSeriesS` | 44.463         | 52852744                  |
| `PmSeriesT` | 48.299         | 61434928                  |
| `PmSeriesV` | 130.754        | 139083856                 |
| `PmSeriesG` | 1.197          | 1206112                   |

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
