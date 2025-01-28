# NanoporeMetaPipeline

## Введение

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

Mail ...

## Цитирование

Если вы используете наш пайплайн в научной публикации, мы будем признательны за ссылки: ...

---------------

## Getting started

This pipeline is designed for amplicon metabarcoding and uses clustering using UMAP-HDBSCAN implemented in NanoCLUST [(Langsiri et al., 2023)](https://doi.org/10.1186/s43008-023-00125-6)

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

Mail ...

## Citation

If you use our pipeline in a scientific publication, we would appreciate citations: ...
