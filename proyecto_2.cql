// Proyecto 2 - Minería de grafos

 // Esteban Gomez Valerio
 // Rafael Takata Garcia
 // Roi Jared Flores Garza Stone

//Conocer el diagrama general del grafo
CALL db.schema.visualization

//Visualizar las relaciones entre Profile y Movie
MATCH (p:Profile)-[a:ADD]->(m:Movie)
RETURN p, a, m

//Modificar dateAdded a Date
MATCH(m:Movie)
SET m.dateAdded = DATE(m.dateAdded)
RETURN m.dateAdded

//Creamos la relación, vistas por la misma persona
//Debido al gasto computacional que implica, lo hacemos por partes:
CALL apoc.periodic.iterate(
  "
  MATCH (p:Profile)-[:ADD]->(shared:Movie)
  MATCH (p)-[:ADD]->(om:Movie)
  WHERE shared < om
  RETURN shared, om
  ",
  "
  MERGE (shared)-[r:VISTAS_JUNTAS]->(om)
  ON CREATE SET r.qty = 1
  ON MATCH SET r.qty = r.qty + 1
  ",
  {batchSize: 1000, parallel: false}
)

//Recomendación basada en categoria
MATCH (perfil:Profile)-[:ADD]->(pelicula:Movie)-[:LISTED_IN]->(categoria:Category)
WITH categoria.name AS nombreCategoria, pelicula.title AS tituloPelicula, COUNT(*) AS totalVistas
ORDER BY nombreCategoria, totalVistas DESC
WITH nombreCategoria, COLLECT(tituloPelicula) AS listaPeliculas
RETURN nombreCategoria AS categoria, listaPeliculas[0..5] AS peliculas

//Recomendación basada en país
MATCH (perfil:Profile)-[:ADD]->(pelicula:Movie)-[:LISTED_IN]->(categoria:Category)
WITH categoria.name AS nombreCategoria, pelicula.title AS tituloPelicula, COUNT(*) AS totalVistas
ORDER BY nombreCategoria, totalVistas DESC
WITH nombreCategoria, COLLECT(tituloPelicula) AS listaPeliculas
RETURN nombreCategoria AS categoria, listaPeliculas[0..5] AS peliculas

//Recomendación basada en actor de mi elección
//Recomendación basada en director de mi elección
//Recomendación basada en año de lanzamamiento

//Creamos el subgrafo
//Dirigido
CALL gds.graph.project(
    'myGraph',
    'Movie',
    {VISTAS_JUNTAS: {
        Properties: 'qty'
        }
    }
)

//Sin dirección
CALL gds.graph.project(
    'myGraphUndirected',
    'Movie',
    {VISTAS_JUNTAS: {
        Properties: 'qty',
        orientation:'UNDIRECTED'
        }
    }
)

//Centralidad 
//PageRank
CALL gds.pageRank.write(
    'myGraph',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pagerank'
    }
)
YIELD nodePropertiesWritten, ranIterations

//Degree
CALL gds.degree.write('myGraphUndirected', { writeProperty: 'degree' })
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, centralityDistribution.mean AS meanScore, nodePropertiesWritten


//betweennessCentrality
CALL gds.betweenness.write( 'myGraph', {writeProperty: 'betweennessCentrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        centralityDistribution.max AS maxScore,
        nodePropertiesWritten

//closenessCentrality
CALL gds.degree.write('myGraph', { writeProperty: 'closenessCentrality' })
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, centralityDistribution.mean AS meanScore, nodePropertiesWritten


//Comunidad
//Louvain
CALL gds.louvain.write('myGraph', {writeProperty: 'louvain'})
YIELD communityCount, modularity, modularities

//labelPropagation
CALL gds.labelPropagation.write('myGraph', {writeProperty:'labelPropagation'})
YIELD communityCount, ranIterations, didConverge

//WCC
CALL gds.wcc.write('myGraphUndirected', {writeProperty:'communityWCC'})
YIELD componentCount, componentDistribution

//SCC
CALL gds.scc.write('myGraph', {writeProperty:'communitySCC'})
YIELD componentCount, componentDistribution

//Similaridad
CALL gds.nodeSimilarity.write('myGraph', {
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'score'
})
YIELD nodesCompared, relationshipsWritten

//NeoDash de Vistas_Juntas
//Centralidad
MATCH(m:Movie)
RETURN m.title, m.pagerank
ORDER BY m.pagerank DESC
LIMIT 5

MATCH(m:Movie)
RETURN m.releaseYear, SUM(m.betweennessCentrality) AS Total_Betweenness
ORDER BY Total_Betweenness DESC


MATCH(m:Movie)
RETURN m.dateAdded.year, AVG(m.closenessCentrality) AS average_closeness
ORDER BY average_closeness DESC
LIMIT 10

MATCH (m:Movie)
RETURN AVG(m.degree) AS degreePromedio

//Community
MATCH(m:Movie)
RETURN m.louvain AS community, COUNT(m.title) AS total_movies, COLLECT(m.title) AS titles
ORDER BY total_movies DESC

MATCH (m:Movie)
RETURN m.labelPropagation, COUNT(m.title) AS total_movies
ORDER BY total_movies DESC
LIMIT 10

MATCH(m:Movie)
RETURN m.communityWCC, COUNT(m.title) AS total_movies
ORDER BY total_movies DESC
LIMIT 10

MATCH(m:Movie)
RETURN COUNT(DISTINCT m.communitySCC) AS diff_communities

//Similarity
MATCH (m:Movie)-[s:SIMILAR]->(om:Movie)
RETURN m.title, SUM(s.score) AS total_score, COLLECT(om.title)
ORDER BY total_score DESC
LIMIT 10

MATCH(m:Movie{title:$neodash_movie_title})-[s:SIMILAR]->(om:Movie)
RETURN s.score, om.title
LIMIT 10

MATCH p =(m:Movie{title:$neodash_movie_title})-[s:SIMILAR]->(om:Movie)
RETURN p
