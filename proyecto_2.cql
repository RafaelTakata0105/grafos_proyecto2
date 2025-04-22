// Proyecto 2 - Minería de grafos

 // Esteban Gomez Valerio
 // Rafael Takata Garcia
 // Roi Jared Flores Garza Stone

//Conocer el diagrama general del grafo
CALL db.schema.visualization

//Visualizar las relaciones entre Profile y Movie
MATCH (p:Profile)-[a:ADD]->(m:Movie)
RETURN p, a, m

//Creamos la relación, vistas por la misma persona

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

