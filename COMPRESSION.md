# Comparison of different compression options

Backupbot lets the user choose between different compression options by setting the `BACKUP_FILE_COMPRESSION=''` and the `BACKUP_MYSQL_COMPRESSION=''` configuration parameters. The following options are available.

| Option | Program | Algorithm | File format | In base | Note |
| ------ | ------- | --------- | ----------- | ------- | ---- |
| NO | none | none | none | yes | |
| 1 | gzip | Deflate (LZ77/Huffman) | `.gz` | yes | |
| 2 | bzip2 | Burrows-Wheeler | `.bz2` | yes | |
| 3 | xz | LZMA | `.xz` | yes | |
| 4 | lz4 | LZ4 | `.lz4` | yes | |
| 5 | ztsd | Zstandard | `.zst` | no | |
| 6 | lrzip | LZMA | `.lrz` | no | |
| 7 | lzip | LZMA | `.lz` | no | |
| 8 | lzop | LZO | `.lzo` | no | |
| 101 | pigz | Deflate (LZ77/Huffman) | `.gz` | no | parallel gzip |
| 102 | pbzip2 | Deflate (LZ77/Huffman) | `.bz2` | no | parallel bzip2 |
| 107 | plzip | LZMA | `.lz` | no | parallel lzip |

## Benchmark

Each of these algorithms has its own strengths and weaknesses. Let's compare them by using their respective default settings on 2 static sites, 1 Wordpress site and a backup of system (`/etc`, `/usr/local/etc`) and log (`/var/log`) files.

| Program | Size | Savings | % Original | % Reduction | Time | +Time | Ratio (reduction/time) |
| ------- | ---- | ------- | ---------- | ----------- | ---- | ----- | ---------------------- |
| none | 119 MB | 0 MB | 100% | 0% | 0,63 s | 0 s | 0,00 |
| gzip | 63 MB | 56 MB | 53% | 47% | 6,67 s | 6,04 s | 8,40 |
| bzip2 | 60 MB | 59 MB | 50% | 50% | 32,93 s | 32,3 s | 1,79 |
| xz | 55 MB | 64 MB | 46% | 54% | 79,36 s | 78,73 s | 0,81 |
| lz4 | 73 MB | 46 MB | 61% | 39% | 0,69 s | 0,06 s | 66,67 |
| zstd | 61 MB | 58 MB | 51% | 49% | 1,35 s | 0,72 s | 42,96 |
| lrzip | 44 MB | 75 MB | 37% | 63% | 14,86 s | 14,23 s | 5,05 |
| lzip | 55 MB | 64 MB | 46% | 54% | 91,37 s | 90,74 s | 0,70 |
| lzop | 74 MB | 45 MB | 62% | 38% | 0,96 s | 0,33 s | 46,88 |
| pigz | 63 MB | 56 MB | 53% | 47% | 1,11 s | 0,48 s | 50,45 |
| pbzip2 | 60 MB | 59 MB | 50% | 50% | 4,65 s | 4,02 s | 12,69 |
| plzip | 55 MB | 64 MB | 46% | 54% | 14,75 s | 14,12 s | 4,34 |

## Conclusions

- lz4, pigz, lzip and zstd perform well, striking a great balance between speed and compression ratio.
- pbzip2, gzip, lrzip and plzip are the middle of the road in terms of speed/compression ratio.
- bzip2, xz and lzip perform very poorly and probably shouldn't be used.
- With their default settings, lrzip, xz, lzip and plzip had the best compression ratio.
- If compression ratio is the most important factor, lrzip will perform the best on similar files with the default settings.
- If speed is the most important factor, none (obviously), lz4, lzop, pigz and zstd will perform well.
- Parallel implementations such as pigz, pbzip2 and plzip offer significantly improved speed with identical compression ratios compared to their single threaded counterparts available in base.

## Recommendations

For similar purposes/use-cases, the following compression programs are recommended.

| Criteria | Program |
| -------- | ------- |
| You need a balanced option | pigz (101) |
| You need the fastest option | lz4 (4) or none (NO) |
| You need the best compression ratio | lrzip (6) |