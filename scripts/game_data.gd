extends Node

var first_time_in_desktop = true

var money = 1000.0

var seen_tutorial = false

var game_result = 'Won'

var day_ptr = 0

var language = 'English'

var difficulty = 'Normal'

var day_length = '2 Min'

var email_dialogue = 'On'

var email_days = [
	"Hey!\n\nA warm welcome to your new job!\n\nYou're tasked with overseeing our nuclear reactor projects, be warned - we're a fast-paced, dynamic company: Expect things to move quickly as we scale our operations.\n\nKindest regards,\nT",
	"Good work yesterday!\nWe've just authorized the startup of JKS I, so please pay attention to that today.\n\nThanks!\nT",
	"Bonsoir my friend!\nThank you for performing so admirably yesterday - it's a pleasure to know you're still aliv--I mean well.\n\nWe're kicking things up a notch today by opening the Manifold reactor.\n\nBest wishes!\nT",
	"Brilliant stuff over the past few days, we at the company are very happy to see you're settling in.\n\nWe thought you might've been getting bored, so we've started the JKS II today, hope to see you tomorrow!\n\nT",
	"Morning employee, our shareholders have decided it will be cheaper to outsource our work. So this will be your final day.\n\nWe've authorized DERICK to be put online. Do not ask me what it stands for, also, this is an experimental reactor, so some quirks may be observed.\n\nAll the best in the future,\nT"
]

var de_email_days = [
	"Hallo! Herzlich willkommen in Ihrem neuen Job!\n\nIhre Aufgabe ist, unsere kerntechnische Tätigkeiten zu überwachen. Seien Sie gewarnt – wir sind ein schnelllebiges und dynamiches Unternehmen.\nErwarten Sie, dass Dinge sich schnell ändern, während wir uns erweitern.\n\nmit freundlichen Grüßen,\nT",
	"Gut gemacht gestern!\n\nWir haben gerade die Betriebung von JKS 1 genehmigt, also sollten Sie das heute überwachen.\n\nDanke!\nT",
	"Ciao mein Freund!\nVielen Dank für die beeindruckende Arbeitsleistung – ich freue mich, zu sehen, dass Sie leben- lebhaft sind.\n\nHeute schalten wir einen Gang höher, indem wir den Verteilungsreaktor öffnen.\n\nAlles liebe!\nT",
	"Sie haben in den letzten Tagen großartige Arbeit geleistet!\n\nWir hier im Unternehmen freuen uns, dass Sie einrichten sich.\n\nWir vermuten, dass Sie vielleicht sich langweilen, deshalb haben wir das JKS II gestartet. Wir hoffen, Sie morgen zu treffen.\n\nT",
	"Guten morgen Mitarbeiter. Unsere Aktionäre haben beschlossen, dass es wird billiger sein, unsere Arbeit auszulagern.\n\nDies wird daher Ihr letzter Tag sein.\nWir haben die Betriebung von DERICK genehmigt. Frag mich nicht, was der Name bedeutet. Er ist auch ein experimenteller Reaktor, also könnte es Macken geben.\n\nIch wünsche Sie viel Glück für die Zukunft.\nT"
]

var sp_email_days = [
	"¡Hola!\n¡Una cálida bienvenida a tu nuevo trabajo!\n\nEstás encargado de supervisar nuestros proyectos de reactores nucleares. Ten en cuenta que somos una empresa dinámica y de ritmo acelerado, así que espera que las cosas avancen rápidamente a medida que ampliamos nuestras operaciones.\n\nAtentamente,\nT",
	"¡Buen trabajo ayer!\n\nAcabamos de autorizar el arranque de JKS I, así que por favor pon atención a eso hoy.\n\n¡Gracias!\nT",
	"¡Buenas noches, mi amigo!\n\nGracias por desempeñarte tan admirablemente ayer. Es un placer saber que sigues viv-- quiero decir, que estás bien.\n\nHoy subimos el nivel abriendo el reactor Manifold.\n\n¡Mis mejores deseos!\nT",
	"¡Trabajo brillante en los últimos días! En la empresa estamos muy felices de ver que te estás adaptando bien.\n\nPensamos que quizás te estabas aburriendo, así que hemos puesto en marcha el JKS II hoy.\n¡Espero verte mañana!\nT",
	"¡Buenos días, empleado!\nNuestros accionistas han decidido que será más barato externalizar nuestro trabajo, así que este será tu último día.\n\nHemos autorizado la puesta en marcha de DERICK. No me preguntes qué significa, además, este es un reactor experimental, por lo que pueden observarse algunas rarezas.\n\nTe deseo lo mejor en el futuro.\nT"
]

var demands = [
	1.1,
	2.0,
	3.5,
	4.0,
	5.0
]

var people = [
	60000,
	100000,
	250000,
	600000,
	1000000
]

var email_voice = [
	"EN_Day1Email.ogg",
	"EN_Day2Email.ogg",
	"EN_Day3Email.ogg",
	"EN_Day4Email.ogg",
	"EN_Day5Email.ogg"
]

var sp_email_voice = [
	"",
	"",
	"",
	"",
	""
]

var de_email_voice = [
	"DE_Day1Email.mp3",
	"DE_Day2Email.mp3",
	"DE_Day3Email.mp3",
	"DE_Day4Email.mp3",
	"DE_Day5Email.mp3"
]

var reactors = [
	{ "name": "Oaxley", "max_output": 1.5, "fuel": "Uranium", "critical_entropy" : 100.0, "critical_temp" : 350.0, "energy_consumed_per_unit_fuel": 10, "coolant_effectiveness": 0.3, "control_rod_effectiveness": 0.05, "bio": "Oaxley was the first and safest reactor that was imported into your country.\n\nConsider it a rite-of-passage for any nuclear overseer." },
	{ "name": "JKS I", "max_output": 1.0, "fuel": "Uranium", "critical_entropy" : 150.0, "critical_temp" : 400.0, "energy_consumed_per_unit_fuel": 10, "coolant_effectiveness": 0.35, "control_rod_effectiveness": 0.1, "bio": "The JKS line is commonly referred to as the 'Gold Standard' of reactors. Sturdy, efficient & controllable. It'll make a fine addition." },
	{ "name": "Manifold", "max_output": 1.0, "fuel": "Plutonium", "critical_entropy": 100.0, "critical_temp" : 500.0, "energy_consumed_per_unit_fuel": 15, "coolant_effectiveness": 0.5, "control_rod_effectiveness": 0.01, "bio": "The Manifold reactor is fueled by Plutonium, it's more expensive to run - and more dangerous - but worthwhile if you can handle it." },
	{ "name": "JKS II", "max_output": 2.0, "fuel": "Plutonium", "critical_entropy": 200.0, "critical_temp" : 500.0, "energy_consumed_per_unit_fuel": 15, "coolant_effectiveness": 0.5, "control_rod_effectiveness": 0.02, "bio": "Like the Manifold, JKS II is a Plutonium based reactor, this will really test your mettle." },
	{ "name": "DERICK", "max_output": 1.0, "fuel": "Uranium", "critical_entropy": 250.0, "critical_temp" : 500.0, "energy_consumed_per_unit_fuel": 10, "coolant_effectiveness": 0.22, "control_rod_effectiveness": 0.05, "bio":"Nuclear Management Inc's greatest, latest reactor - a true beast with no bars held. Good luck." }
]

func increment_day():
	day_ptr += 1
