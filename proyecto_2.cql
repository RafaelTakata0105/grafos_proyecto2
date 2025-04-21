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
