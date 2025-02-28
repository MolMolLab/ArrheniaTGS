# ArrheniaTGS

## Описание

С развитием технологий таргетного секвенирования значительно расширилась возможность массового получения длинных прочтений. TGS позволяет секвенировать полный регион ITS в целях метабаркодинга, изучения распространения видов и получения последовательностей ДНК из сложных образцов. Однако TGS характеризуется меньшей точностью прочтений по сравнению с NGS, что создает проблемы для анализа данных, особенно при использовании традиционных методов кластеризации, такой как жадная кластеризация, которые плохо справляются с обработкой длинных и шумных последовательностей.

Для решения этой проблемы был предложен метод UMAP-HDBSCAN ([Armstrong et al. 2021](https://doi.org/10.1128/mSystems.00691-21), [McInnes et al. 2017](https://doi.org/10.21105/joss.00205)), который показал свою эффективность при анализе данных TGS искусственных сообществ грибных патогенов человека [(Langsiri et al., 2023)](https://doi.org/10.1186/s43008-023-00125-6). Этот метод основан на построении взвешенного графа с последующим определением кластеров, что позволяет более точно группировать длинные последовательности.

Для обработки данных полученных с помощью Nanopore был разработан пайплайн ArrheniaTGS на Bash и Python 3

Основные этапы ArrheniaTGS: 
+ Выделение в данных секвенирования региона ITS удалением первых 80 оснований и всех, начиная с 700-го
+ кластеризация последовательностей с использованием UMAP-HDBSCAN, имплементированного в NanoCLUST [(Rodríguez-Pérez et al., 2021)](https://doi.org/10.1093/bioinformatics/btaa900)
+ множественное выравнивание последовательностей внутри кластера с помощью [Minimap2](https://github.com/lh3/minimap2?ysclid=m7olzmmeet636421973)
+ получение консенсусной последовательности с использованием [Racon](https://doi.org/10.1101/gr.214270.116) и [Medaka](https://github.com/nanoporetech/medaka?ysclid=m7om4332mb346225401)
+ классификация с помощью [BLAST+](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html) и референсной базы [UNITE (fungal ITS)](https://unite.ut.ee/repository.php)

Входные данные: демультиплицированные FastQ файлы результатов секвенирования на Nanopore.
Результат: .xls таблица классифицированных последовательностей и их частот, .qza артефакт последовательностей и их частот для дальнейшего анализа в [Qiime2](https://qiime2.org/).

Результаты обработки данных секвенирования полного ITS на Nanopore с использованием ArrheniaTGS сопоставимы с результатами секвенирования ITS2 Illumina MiSeq обработанными ArrheniaNGS по числу и частотной композиции таксономических единиц. Однако ArrheniaTGS позволяет качественно обрабатывать длинные и шумные прочтения Nanopore и получать пригодные для дальнейшего филогенетического анализа последовательности полного ITS.

Данный пайплайн разработан для метабаркодинга ампликонов и использует кластеризацию с применением UMAP-HDBSCAN, реализованного в NanoCLUST [(Langsiri et al., 2023)](https://doi.org/10.1186/s43008-023-00125-6)

## Установка
### Зависимости
- Linux
- [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
- seqkit
- [Docker](https://docs.docker.com/engine/install/)
- [NanoCLUST](https://gitlab.com/piroonj/ont_clustering/-/tree/main?ref_type=heads)
------------

Скопируйте `script.sh` в директорию с NanoCLUST.

## Использование

Чтобы просмотреть доступные параметры, выполните:
```bash
./script.sh -h
``` 

Пример запуска:
```bash
./script.sh --conda-env my_env --conda-dir /home/user/miniconda3
```

Результатом работы будет таксономическая таблица в формате .tsv для каждого индекса.

## Контакты

Mail: sibmyco@gmail.com

## Цитирование

Ишманов Т.Ф., Звягина Е.А., Филиппов И.В., Филиппова Н.В. ArrheniaTGS. https://github.com/MolMolLab/ArrheniaTGS

---------------

## Description


With the advancement of targeted sequencing technologies, the ability to obtain long reads on a large scale has significantly expanded. TGS enables the sequencing of the entire ITS region for metabarcoding, species distribution studies, and obtaining DNA sequences from complex samples. However, TGS is characterized by lower read accuracy compared to NGS, which poses challenges for data analysis, especially when using traditional clustering methods such as greedy clustering, which struggle with processing long and noisy sequences.

To address this issue, the UMAP-HDBSCAN method was proposed ([Armstrong et al. 2021](https://doi.org/10.1128/mSystems.00691-21), [McInnes et al. 2017](https://doi.org/10.21105/joss.00205)). This method is based on constructing a weighted graph followed by cluster identification, which enables more accurate grouping of long sequences. NanoCLUST [(Rodríguez-Pérez et al., 2021)](https://doi.org/10.1093/bioinformatics/btaa900) is a developed tool for processing 16S nanopore data using UMAP-HDBSCAN. It has demonstrated its effectiveness in analyzing  ITS1-5.8S-ITS2 TGS data from artificial communities of human fungal pathogens [(Langsiri et al., 2023)](https://doi.org/10.1186/s43008-023-00125-6).

We adapted NanoCLUST to ITS1-5.8S-ITS2 in ArrheniaTGS and used this pipeline to analyze metabarcoding data from natural fungal communities. The ArrheniaTGS pipeline was developed using Bash and Python 3.

The main stages of ArrheniaTGS:

+ Extraction of the ITS region from sequencing data by removing the first 80 bases and all bases starting from the 700th
+ Clustering of sequences using UMAP-HDBSCAN, implemented in NanoCLUST
+ Multiple sequence alignment within clusters using [Minimap2](https://github.com/lh3/minimap2?ysclid=m7olzmmeet636421973)
+ Consensus sequence generation using [Racon](https://doi.org/10.1101/gr.214270.116) and [Medaka](https://github.com/nanoporetech/medaka?ysclid=m7om4332mb346225401)
+ Classification using [BLAST+](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html) and the [UNITE](https://unite.ut.ee/repository.php)
 reference database (fungal ITS)

Input data: demultiplexed FastQ files from Nanopore sequencing results.

Output: an `.xls` table of classified sequences and their frequencies, and a `.qza` `FeatureTable[Frequency]`, `FeatureData[Sequence]` and `FeatureData[Taxonomy]` artifacts for further analysis in Qiime2.

The results of full ITS sequencing data processing on Nanopore using ArrheniaTGS are comparable to the results of ITS2 sequencing on Illumina MiSeq processed with ArrheniaNGS in terms of the number of OTUs and frequency composition.

However, ArrheniaTGS enables high-quality processing of long and noisy Nanopore reads, producing sequences of the full-length ITS1-5.8S-ITS2 region that are suitable for further phylogenetic analysis.

## Installation
### Dependencies
- Linux
- [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
- seqkit
- [Docker](https://docs.docker.com/engine/install/)
- [NanoCLUST](https://gitlab.com/piroonj/ont_clustering/-/tree/main?ref_type=heads)
------------

Copy `script.sh` to the directory with NanoCLUST.

## Usage

To view available options, run:
```bash
./script.sh -h
``` 

Launch example:
```bash
./script.sh --conda-env my_env --conda-dir /home/user/miniconda3
```

The result of the work will be a taxonomic table in .tsv format for each index.

## Communication

Mail: sibmyco@gmail.com

## Citation

Ishmanov T.F., Zvyagina E.A., Filippov I.V., Filippova N.V. ArrheniaTGS. https://github.com/MolMolLab/ArrheniaTGS
