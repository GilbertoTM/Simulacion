/**
* Name: SimulacionEnfermedad
* Trata de simular como una contagiosa enfermedad respiratoria (como la gripe) se esparce por el campus universitario
 
* Author: Gilberto
* Tags: 
*/


model SimulacionEnfermedad
	
	global{
		float distanciaEd <- 10.0;
		int personasInicio <- 2000;
		int Infectadas <- 5;
		bool todosInfectados <- false;
		int personasInmunes <- 3;
		int personas <- 0;
		float proba <- 0.40;
		float probabilidadCuracion <- 0.01;
		float distInfeccion <- 0 #m;
		int numPerVivas <- personasInicio;
		int numEdificios <- 10;
		
		float step <- 0.8#mn;
		geometry shape<-square(2000 #m); //Define la forma del entorno.
		reflex terminarSimulacion when: contPersonas = 1000{
			do pause;
		} 
		int contPersonas <- personas update: gente count (each.personaMuerta);
		int numInfectadas <- Infectadas update: gente count (each.boolInfectado);
		int noInfectado <- personasInicio - Infectadas update: personasInicio - numInfectadas;
		float porcentajeInf update: numInfectadas/personasInicio;
		
		init{ //Define el comportamiento en un inicio de la simulacion
			create gente number: personasInicio;
			 //crea las 2000 personas.
			create inmunes number: personasInmunes;
			//create edicios number:numEdificios;
			
			//FCQI
			create edicios number: 1 with: (location:{925.0,200.0}, VA:2); //6G
			create edicios number: 1 with: (location:{1100.0,200.0}, VA:2); //6H
			create edicios number: 1 with: (location:{850.0,600.0}, VA:0); //6E
			create edicios number: 1 with: (location:{1000.0,400.0}, VA:0); //6J
			create edicios number: 1 with: (location:{1100.0,600.0}, VA:0); //6K
			create edicios number: 1 with: (location:{875.0,780.0}, VA:2); //6A
			create edicios number: 1 with: (location:{875.0,925.0}, VA:0); //6B
			create edicios number: 1 with: (location:{725.0,925.0}, VA:0); //6D
			create edicios number: 1 with: (location:{770.0,1050.0}, VA:0); //6C


			//ODONTOLOGIA
			create edicios number: 1 with: (location:{80.0,60.0}, VA:3); //3F
			create edicios number: 1 with: (location:{555.0,925.0}, VA:3); //3A
			create edicios number: 1 with: (location:{555.0,1100.0}, VA:3.5); //3B
			create edicios number: 1 with: (location:{555.0,800.0}, VA:3.5); //3A+
			create edicios number: 1 with: (location:{555.0,725.0}, VA:3.5); //3A++
			create edicios number: 1 with: (location:{400.0,1300.0}, VA:3); //3E
			create edicios number: 1 with: (location:{550.0,1300.0}, VA:3.2); //3C
			create edicios number: 1 with: (location:{420.0,1450.0}, VA:3.2); //3D




			//DERECHO
			create edicios number: 1 with: (location:{350.0,830.0}, VA:4); //4C
			create edicios number: 1 with: (location:{390.0,780.0}, VA:4); //4D
			create edicios number: 1 with: (location:{425.0,950.0}, VA:4); //4E
			create edicios number: 1 with: (location:{325.0,950.0}, VA:4); //4A
			create edicios number: 1 with: (location:{400.0,1100.0}, VA:4.2); //4F



			
			
			//Cafeteria
			create edicios number: 1 with: (location:{1100.0,800.0}, VA:1); 
			
			//


			
			
			
			
			ask Infectadas among gente {
				boolInfectado <- true;
			}	
		}
		
	}


species edicios{
	float VA;
	aspect aspectoDeEdificio {
		if VA = 0{
		draw square(100) color: #green;	
		}
		if VA = 1{
			draw square(100) color: #black;
		}
		if VA = 2{
			draw square(80) color: #green;
		}
		if VA = 3{
			draw square(120) color: #blue;
		}
		if VA =3.2{
			draw square(80)color: #blue;
		}
		if VA = 3.5{
			draw rectangle(130#m,40#m) color: #blue;
		}
		if VA = 4{
			draw rectangle(80#m,40#m) color: #red;
		}
		if VA =4.2{
			draw rectangle(130#m,40#m) color: #red;
		}
	}
}	
	
species gente skills: [moving]{
	float vel <- (1 + rnd(2)) #km/#h; //velocidad de 2-5 k/h
	bool boolInfectado <- false; //inicializamos que las personas no estan infectadas
	bool personaMuerta <- false;
	point coor;
	edicios obj;
	float duracion <- 160 #mn;
	
	reflex cerca when: obj = nil{
		ask edicios at_distance(distanciaEd) {
			myself.obj <- self;
		}
	}
	
	
	reflex seguir when: obj!=nil{
	vel <- 0.8;
	loop times: 60#m{
		do goto target: obj;
		}
	}
	
	
	
	reflex move{
		do wander; //Esto hace que gracias a algun estimulo se mueva de manera aleatoria 
	}
	
	reflex infectado when: boolInfectado{ //este reflejo se activa si el agentre esta infectado
		ask gente at_distance distInfeccion #m { //este se activa a las personas no infectadas si es que estan dentro de 5 metros
			if flip (proba) { //genera un evento que tendra 40% de probabilidad de ser verdad
				boolInfectado <- true; //de ser verdad el agente se infectara (el agente cercano al agente infectado)
			}
		}
	}
 
	reflex morirPorInfeccion when: boolInfectado = true {
	    if flip(0.001) { // Probabilidad de 0.1% de morir por infección en cada paso de tiempo
	    	personaMuerta <- true;
	    	numPerVivas <- numPerVivas - 1;
	        do die;  //El agente infectado muere
	    }
	}
	
	reflex curarInfeccion when: boolInfectado = true {
	    if flip(probabilidadCuracion) { // Probabilidad de curación en cada paso de tiempo
	        boolInfectado <- false; // El agente infectado se cura
	    }
	}
	
	aspect aspectoDeAgentes {
		draw circle(8) color:boolInfectado ? #red : #black; //(is_infected == true), el color será rojo (#red), de lo contrario, será verde (#green).
	}
	
}

species inmunes skills: [moving]{
	float vel <- (1 + rnd(2)) #km/#h; //velocidad de 2-5 k/h
	bool boolInfectado <- false;
	
	
	 reflex infectado when: boolInfectado{ //este reflejo se activa si el agentre esta infectado
		ask inmunes at_distance distInfeccion #m { //este se activa a las personas no infectadas si es que estan dentro de 5 metros
			if flip (proba) { //genera un evento que tendra 40% de probabilidad de ser verdad
				boolInfectado <- true; //de ser verdad el agente se infectara (el agente cercano al agente infectado)
			}
		}
	}
	
	reflex move{
		do wander; //Esto hace que gracias a algun estimulo se mueva de manera aleatoria 
	}
	
	aspect aspectoDeImunes {
		draw circle(8) color: #blue; //(is_infected == true), el color será rojo (#red), de lo contrario, será verde (#green).
	}
}
/* Insert your model definition here */



experiment prueba1Visual type: gui {
	parameter "Num de personas inmunes" var: personasInmunes min: 0 max: 10;
	parameter "Num de personas infectadas al inicio" var:Infectadas min: 1 max: personasInicio;
	parameter "Probabilidad de infeccion" var: proba min: 0.05 max: 0.99;
	parameter "Distancia de infeccion" var:distInfeccion min: 1#m max:15#m;
	parameter "Probabilidad de curacion" var:probabilidadCuracion min:0.001 max:1.0;
	parameter "Numero de Personas" var: personasInicio min:1 max:2500;
		
	// Define parameters here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }
	
	
	output {
	// Define inspectors, browsers and displays here
	display map{
		species gente aspect: aspectoDeAgentes; //Este nos permite ver la especie declarada con la forma y colores que hemos establecido
		species inmunes aspect: aspectoDeImunes;
		species edicios aspect: aspectoDeEdificio;
	}
	display chart_display refresh: every(10 #cycles)  type: 2d {
			chart "Grafica infectado/no_infectado" type: series {
				data "Infectados" value: numInfectadas color: #red;
				data "no-infectado" value: noInfectado color: #blue;
				data "num-Personas" value: numPerVivas color: #green;
			}
		}

	}
}