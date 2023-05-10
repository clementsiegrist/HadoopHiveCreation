# Hadoop-Hive-IMDB Database

This project contains a Dockerfile and instructions for creating a Hadoop and Hive-based IMDB database. The Docker image includes Hadoop, Hive, and the necessary configurations to set up the environment. The instructions provided will walk you through creating the Hive tables, populating them with IMDB data, and running sample queries.

## Getting Started

1. Build the docker image

`docker build -t hadoop-hive-imdb .`

2. Run a Docker container using the created image:

`docker run -it --name hadoop-hive-imdb-container -p 10000:10000 hadoop-hive-imdb`

3. To begin, download the IMDB data files: 

`wget https://datasets.imdbws.com/name.basics.tsv.gz`
`wget https://datasets.imdbws.com/title.akas.tsv.gz`
`wget https://datasets.imdbws.com/title.basics.tsv.gz`
`wget https://datasets.imdbws.com/title.crew.tsv.gz`                    
`wget https://datasets.imdbws.com/title.episode.tsv.gz`    
`wget https://datasets.imdbws.com/title.principals.tsv.gz`
`wget https://datasets.imdbws.com/title.ratings.tsv.gz`

4. Unzip the downloaded files:

`gzip -d *.tsv.gz`

5. Run the following command to create the /imdb-data/ directory:

`hadoop fs -mkdir /imdb-data`

6. Next, copy the uncompressed data files into HDFS:

`hadoop fs -put name.basics.tsv /imdb-data/`
`hadoop fs -put title.akas.tsv /imdb-data/`
`hadoop fs -put title.basics.tsv /imdb-data/`
`hadoop fs -put title.crew.tsv /imdb-data/`
`hadoop fs -put title.episode.tsv /imdb-data/`
`hadoop fs -put title.principals.tsv /imdb-data/`
`hadoop fs -put title.ratings.tsv /imdb-data/`

7. To connect to Hive, use the following command:

`hive`

## Create and Populate IMDB Database


1. Create a database for the IMDB data:

`CREATE DATABASE imdb;`
`USE imdb`

2. Create tables using the appropriate schemas and storage optimizations for each data file. Optimizations include using ORC compression for storage and selecting appropriate data types for each column.

`CREATE TABLE name_basics (`
  `nconst STRING,`
  `primaryName STRING,`
  `birthYear INT,`
  `deathYear INT,`
  `primaryProfession ARRAY<STRING>,`
  `knownForTitles ARRAY<STRING>)` 
  `ROW FORMAT DELIMITED`
`FIELDS TERMINATED BY '\t'`
`COLLECTION ITEMS TERMINATED BY ','`
`STORED AS ORC;`

`CREATE TABLE title_akas (`
  `titleId STRING,`
  `ordering INT,`
  `title STRING,`
  `region STRING,`
  `language STRING,`
  `types STRING,`
  `attributes STRING,`
  `isOriginalTitle BOOLEAN`
`) ROW FORMAT DELIMITED`
`FIELDS TERMINATED BY '\t'`
`STORED AS ORC;`

3. Load data into the created tables:

`LOAD DATA INPATH '/imdb-data/name.basics.tsv' OVERWRITE INTO TABLE name_basics;`
`LOAD DATA INPATH '/imdb-data/title.akas.tsv' OVERWRITE INTO TABLE title_akas;`

## Example Queries

1. Find the top 10 highest rated movies:

`SELECT tb.primaryTitle, tr.averageRating, tr.numVotes`
`FROM title_basics tb`
`JOIN title_ratings tr ON tb.tconst = tr.tconst`
`WHERE tb.titleType = 'movie'`
`ORDER BY tr.averageRating DESC, tr.numVotes DESC`
`LIMIT 10;`

2. Find the main actors in "The Shawshank Redemption":

`SELECT nb.primaryName`
`FROM title_basics tb`
`JOIN title_principals tp ON tb.tconst = tp.tconst`
`JOIN name_basics nb ON tp.nconst = nb.nconst`
`WHERE tb.primaryTitle = 'The Shawshank Redemption'`
`AND tp.category IN ('actor', 'actress');`

3. Find the 10 most prolific directors:

`SELECT nb.primaryName, COUNT(DISTINCT tc.tconst) AS movie_count`
`FROM name_basics nb`
`JOIN title_crew tc ON nb.nconst = tc.director`
`WHERE tc.tconst IN (SELECT tconst FROM title_basics WHERE titleType = 'movie')`
`GROUP BY nb.primaryName`
`ORDER BY movie_count DESC`
`LIMIT 10;`

4. Find the top 10 TV series with the most episodes:

`SELECT tb.primaryTitle, COUNT(te.episode) AS episode_count`
`FROM title_basics tb`
`JOIN title_episode te ON tb.tconst = te.parentTconst`
`WHERE tb.titleType = 'tvSeries'`
`GROUP BY tb.primaryTitle`
`ORDER BY episode_count DESC`
`LIMIT 10;`

5. Find the top 5 most famous actors/actresses born in 1990:

`SELECT nb.primaryName, COUNT(tp.tconst) AS known_for_count`
`FROM name_basics nb`
`JOIN title_principals tp ON nb.nconst = tp.nconst`
`WHERE nb.birthYear = 1990`
  `AND tp.category IN ('actor', 'actress')`
`GROUP BY nb.primaryName`
`ORDER BY known_for_count DESC`
`LIMIT 5;`

## Cleanup

Once you have finished exploring the IMDB database, you may want to clean up your environment. To do so, follow the steps below:

1. Exit the Hive CLI by typing `exit`; or pressing `Ctrl + D`.

2. Stop and remove the Docker container:

`docker stop hadoop-hive-imdb-container`
`docker rm hadoop-hive-imdb-container`

3. Optionally, remove the Docker image:

`docker rmi hadoop-hive-imdb`

4. Delete the downloaded IMDB data files and HDFS directory:

`rm name.basics.tsv title.akas.tsv title.basics.tsv title.crew.tsv title.episode.tsv title.principals.tsv title.ratings.tsv`
`hadoop fs -rm -r /imdb-data`

## Troubleshooting

If you encounter any issues while setting up or using the IMDB database, please consult the following resources:

    [Hadoop documentation](https://hadoop.apache.org/docs/stable/)
    [Hive](https://cwiki.apache.org/confluence/display/Hive/Home)

For additional help, you may also reach out to the community through forums such as Stack Overflow or the Apache Hive mailing list.
Contributing

Contributions to this project are welcome! If you have suggestions for improvements or encounter any issues, please open an issue or submit a pull request on the project's GitHub repository.

## License

This project is licensed under the MIT License. Please see the LICENSE file for more information.