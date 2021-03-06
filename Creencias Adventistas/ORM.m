//
//  ORM.m
//  Creencias Adventistas
//
//  Created by Daniel Scholtus on 28/07/13.
//  Copyright (c) 2013 Daniel Scholtus. All rights reserved.
//

#import "ORM.h"

@interface ORM () {
    
}

@end

@implementation ORM

static NSManagedObjectContext *sManagedObjectContext;
static NSManagedObjectModel *sManagedObjectModel;
static NSPersistentStoreCoordinator *sPersistentStoreCoordinator;
static NSMutableDictionary *sFetchedResultsControllers;

# pragma mark - Core Data Stack management

+ (void)initialize {
    
    // Document directory
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager]
                                             URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask] lastObject];
    
    // Managed Object Model
    NSURL *modelURL = [[NSBundle mainBundle]
                       URLForResource:@"Creencias_Adventistas"
                       withExtension:@"momd"];
    sManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Persistent Store Coordinator
    //NSURL *storeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Creencias_Adventistas_pre" ofType:@"sqlite"]];
    
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:NSLocalizedString(@"dbpath", nil)];
    
    /*
    NSLog(@"About to get nasty");
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Creencias_Adventistas" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
     }
    }
     */
    
    NSError *error = nil;
    sPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:sManagedObjectModel];
    if (![sPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        /*
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path.
         Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Managed Object Context
    sManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [sManagedObjectContext setPersistentStoreCoordinator:sPersistentStoreCoordinator];
    
    [ORM prefillDatabase];
}

+ (void)saveContext
{
    NSError *error = nil;
    if (sManagedObjectContext != nil) {
        if ([sManagedObjectContext hasChanges] && ![sManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

# pragma mark - Objects instantiation

+ (ORM *)factory:(NSString *)entity
{
    [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [NSEntityDescription
                insertNewObjectForEntityForName:entity
                inManagedObjectContext:sManagedObjectContext];

    return orm;
}

+ (ORM *)factory:(NSString *)entity withValues:(NSDictionary *)values
{
    [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [NSEntityDescription
                insertNewObjectForEntityForName:entity
                inManagedObjectContext:sManagedObjectContext];
    [orm setValuesForKeysWithDictionary:values];
    return orm;

}

+ (ORM *)factory:(NSString *)entity at:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    ORM *orm = [fetchedResultsController objectAtIndexPath:indexPath];
    return orm;
}

#pragma mark - Fetched Results Controllers Handling

+ (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString *)entity
{
    NSFetchedResultsController *fetchedResultsController = [sFetchedResultsControllers objectForKey:entity];
    if (fetchedResultsController) {
        // The Fetched Results Controller exists, no need to recreate
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entityDescription = [NSEntityDescription
                                   entityForName:entity
                                   inManagedObjectContext:sManagedObjectContext];
    
    [fetchRequest setEntity:entityDescription];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:28];
    
    // Edit the sort key as appropriate.
   // NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[
                    [NSSortDescriptor sortDescriptorWithKey:@"section"
                                   ascending:YES],
                    [NSSortDescriptor sortDescriptorWithKey:@"index"
                                                                     ascending:YES]]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    fetchedResultsController = [[NSFetchedResultsController alloc]
                                initWithFetchRequest:fetchRequest
                                managedObjectContext:sManagedObjectContext
                                sectionNameKeyPath:@"section"
                                cacheName:@"Master"];
    
    [sFetchedResultsControllers setObject:fetchedResultsController  forKey:entity];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}

+ (void)setFetchedResultsControllerDelegate:(id)delegate forEntity:(NSString *)entity {
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    fetchedResultsController.delegate = delegate;
}

#pragma mark - Fetched Results Controllers querying

/** Get the sections count */
+ (int)sectionsForEntity:(NSString *)entity
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    
    return [[fetchedResultsController sections] count];
}

/** Get the entities count for a section */
+ (int)entities:(NSString *)entity forSection:(NSInteger)section
{
    NSFetchedResultsController *fetchedResultsController = [ORM fetchedResultsControllerForEntity:entity];
    
    return [[fetchedResultsController sections][section] numberOfObjects];

}

# pragma mark - Database prefilling

+ (void)prefillDatabase
{
    if ([ORM sectionsForEntity:@"Belief"] == 0) {
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @0,
         @"section" : @0,
         @"title" : NSLocalizedString(@"0title", nil),
         }];
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @1,
         @"section" : @0,
         @"title" : @"Doctrina del Hombre",
         }];
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @2,
         @"section" : @0,
         @"title" : @"Doctrina de la Salvación",
         }];
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @3,
         @"section" : @0,
         @"title" : @"Doctrina de la Iglesia",
         }];
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @4,
         @"section" : @0,
         @"title" : @"Doctrina de la Vida Cristiana",
         }];
        
        [ORM factory:@"Doctrine" withValues:@{
         @"index" : @5,
         @"section" : @0,
         @"title" : @"Doctrina de los Acontecimientos Finales",
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Las Santas Escrituras",
         @"content" : @"Las Santas Escrituras, el Antiguo y el Nuevo Testamento, son la Palabra de Dios escrita, dada por inspiración divina por intermedio de santos hombres de Dios que hablaron y escribieron al ser movidos por el Espíritu Santo. En esta Palabra, Dios ha transmitido al ser humano el conocimiento necesario para la Salvación. Las Santas Escrituras son la infalible revelación de la voluntad divina. Son la norma para el carácter, la prueba de la experiencia, la revelación autorizada de doctrinas, y el registro confiable de la actuación de Dios en la historia.\n\n2 Pedro 1:20 y 21; 2 Timoteo 3:16 y 17; Salmo 119:105; Proverbios 30:5 y 6; Isaías 8:20; Juan 10:35; Juan 17:17; 1 Tesalonicenses 2:13; Hebreos 4:12.",
         @"section" : @0,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Trinidad",
         @"content" : @"Hay un solo Dios: Padre, Hijo y Espíritu Santo, una unidad de tres Personas coeternas. Dios es inmortal, omnipotente, omnisciente, por encima de todo (trascendente), y siempre presente. Es infinito y está más allá de la comprensión humana, aunque es conocido por su revelación de sí mismo. Es eternamente digno de alabanza, adoración y servicio por toda la creación.\n\nDeuteronomio 6:4; Deuteronomio 29:29; Mateo 28:19; 2 Corintios 13:14; Efesios 4:4-6; 1 Pedro 1:2; 1 Timoteo 1:17; Apocalipsis 14:6 y 7.",
         @"section" : @0,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Dios Padre",
         @"content" : @"Dios, el Eterno Padre, es el Creador, el Originador, el Sustentador y el Soberano de toda la creación. Él es justo y santo, misericordioso y clemente, tardo en airarse, y grande en constante amor y fidelidad. Las cualidades y poderes mostrados en el Hijo y en el Espíritu Santo son, también, revelaciones del Padre.\n\nGénesis 1:1; Apocalipsis 4:11; 1 Corintios 15:28; Juan 3:16; 1 Juan 4:8; 1 Timoteo 1:17: Éxodo 34:6 y 7; Juan 14:9.",
         @"section" : @0,
         @"index" : @2,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Dios Hijo",
         @"content" : @"Dios, el Hijo Eterno, se encarnó en Jesucristo. Por medio de Él todas las cosas fueron creadas, se revela el carácter de Dios, se consuma la salvación de la humanidad y es juzgado el mundo. Verdadero Dios por siempre, también llegó a ser verdaderamente hombre, Jesús el Cristo. Fue concebido por el Espíritu Santo, y nació de la virgen María. Vivió y experimentó la tentación como ser humano, y ejemplificó perfectamente la justicia y el amor de Dios. A través de sus milagros demostró el poder de Dios y fue atestiguado como el Mesías prometido por Dios. Jesús sufrió y murió voluntariamente en la cruz en nuestro lugar por nuestros pecados, fue resucitado de entre los muertos y ascendió para ministrar en el santuario celestial en nuestro favor. Vendrá de nuevo en gloria para la liberación final de Su pueblo y la restauración de todas las cosas.\n\nJuan 1:1-3 y14; Colosenses 1:15-19; Juan 10:30; Juan 14:9; Romanos 5:18; Romanos 6:23; 2 Corintios 5:17-19; Juan 5:22; Lucas 1:35; Filipenses 2:5-11; Hebreos 2:9-18; 1 Corintios 15:3 y 4; Hebreos 4:15; Hebreos 7:25; Hebreos 8:1 y 2; Hebreos 9:28; Juan 14:1-3; 1 Pedro 2:21; Apocalipsis 22:20.",
         @"section" : @0,
         @"index" : @3,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Dios Espíritu Santo",
         @"content" : @"Dios, el Espíritu Santo, desempeñó una parte activa con el Padre y el Hijo en la Creación, encarnación y redención. Inspiró a los escritores de las Escrituras. Llenó la vida de Cristo con poder. Llama y convence a los seres humanos; y a aquellos que le responden, les renueva y transforma a la imagen de Dios. Enviado por el Padre y por el Hijo para permanecer para siempre con sus hijos, concede dones espirituales a la Iglesia, la capacita para dar testimonio de Cristo, y en armonía con las Escrituras, la guía a toda verdad.\n\nGénesis 1:1 y 2; Lucas 1:35; Lucas 4:18; Hechos 10:38; 2 Pedro 1:21; 2 Corintios 3:18; Efesios 4:11 y 12; Hechos 1:8; Juan 14:16-18 y 26; Juan 15:26 y 27; Juan 16:7-13.",
         @"section" : @0,
         @"index" : @4,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Creación",
         @"content" : @"Dios es el Creador de todas las cosas, y ha revelado en las Escrituras el auténtico relato de Su actividad creadora. En seis días el Señor hizo “el cielo y la Tierra” y todo lo que tiene vida sobre la Tierra, y descansó el séptimo día de esa primera semana. De este modo estableció el Sábado como un memorial permanente de su trabajo creativo completo. El primer hombre y la primera mujer fueron creados a la imagen de Dios como coronación de la Creación, se les dio dominio sobre el mundo y se les dio la responsabilidad de cuidarlo. Cuando el mundo fue terminado, era “muy bueno”, anunciando así la gloria de Dios.\n\nGénesis 1 y 2; Éxodo 20:8-11; Salmo 19:1-6; Salmo 33:6 y 9; Salmo 104; Hebreos 11:3; Juan 1:1-3; Colosenses 1:16 y 17.",
         @"section" : @1,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Naturaleza del Hombre",
         @"content" : @"El hombre y la mujer fueron formados a imagen de Dios con individualidad, con el poder y la libertad de pensar y actuar. Aunque fueron creados como seres libres, cada uno es una unidad indivisible de cuerpo, mente y espíritu, dependientes de Dios para la vida, el aliento y todo lo demás. Cuando nuestros primeros padres desobedecieron a Dios, negaron su dependencia de Él y cayeron de su elevada posición bajo Dios. La imagen de Dios en ellos fue desfigurada, pasando a estar sujetos a la muerte. Sus descendientes comparten esa naturaleza caída y sus consecuencias. Nacen con las debilidades y tendencias al mal. Pero Dios en Cristo reconcilió consigo al mundo y a través de su Santo Espíritu restaura en los mortales penitentes la imagen de su Hacedor. Creados para la gloria de Dios, son llamados a amarle y amarse los unos a los otros, y cuidar del medio ambiente.\n\nGénesis 1:26-28; Génesis 2:7; Salmo 8:4-8; Hechos 17:24-28; Génesis 3; Salmo 51:5; Romanos 5:12-17; 2 Corintios 5:19 y 20; Salmo 51:10; 1 Juan 4:7-8, 11, 20; Génesis 2:15.",
         @"section" : @1,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Gran Conflicto",
         @"content" : @"Toda la humanidad está involucrada en un gran conflicto entre Cristo y Satanás, en cuanto al carácter de Dios, su Ley y su soberanía sobre el Universo. Ese conflicto se originó en el Cielo, cuando un ser creado, dotado de libertad de elección, por exaltación propia se convirtió en Satanás, el adversario de Dios, y guió a la rebelión a una parte de los ángeles. Él introdujo el espíritu de rebelión en este mundo cunado indujo a Adán y Eva a pecar. El pecado de la humanidad distorsionó la imagen de Dios en el ser humano, el desorden en el mundo creado y su eventual devastación en el momento del diluvio mundial. Observado por toda la Creación, este mundo se convirtió en el escenario del conflicto universal, del cual será finalmente reivindicado el Dios de amor. Para asistir a su pueblo en esta controversia, Cristo envía su Santo Espíritu y ángeles leales para guiar, proteger, y sostenerlos en el camino de la Salvación.\n\nApocalipsis 12:4-9; Isaías 14:12-14; Ezequiel 28:12-18; Génesis 3; Romanos 1:19-32; Romanos 5:19-21; Romanos 8:19-22; Génesis 6-8; 2 Pedro 3:6; 1 Corintios 4:9; Hebreos 1:14.",
         @"section" : @2,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Vida, Muerte y Resurrección de Cristo",
         @"content" : @"En la vida de Cristo, de perfecta obediencia a la voluntad de Dios, en su sufrimiento, muerte y resurrección, Dios proveyó el único medio de expiación del pecado humano, de modo que los que aceptan por fe esa expiación, puedan tener vida eterna, y toda la Creación comprenda mejor el infinito y santo amor del Creador. Esta perfecta expiación vindica la justicia de la ley de Dios y la gracia de su carácter; ya que a la misma vez, condena nuestros pecados, y hace provisión para nuestro perdón. La muerte de Cristo es sustitutoria y expiatoria, reconciliando y transformando. La resurrección de Cristo proclama el triunfo de Dios sobre las fuerzas del mal, y para aquellos que aceptan la expiación les asegura la victoria final sobre el pecado y la muerte. Declara el señorío de Jesucristo, ante quien se doblará toda rodilla en el cielo y en la Tierra.\n\nJuan 3:16; Isaías 53; 1 Pedro 2:21-22; 1 Corintios 15:3-4, 20-22; 2 Corintios 5:14-15, 19-21; Romanos 1:4; Romanos 3:25; Romanos 4:25; Romanos 8:3-4; 1 Juan 2:2; 1 Juan 4:10; Colosenses 2:15; Filipenses 2:6-11.",
         @"section" : @2,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Experiencia de la Salvación",
         @"content" : @"En infinito amor y misericordia, Dios permitió que Cristo, quien no conoció pecado, se convirtiese en pecado por nosotros, para que en Él fuésemos hechos justicia de Dios. Guiados por el Espíritu Santo sentimos nuestra necesidad, reconocemos nuestra pecaminosidad, nos arrepentimos de nuestras transgresiones y ejercemos fe en Jesús como Señor y Cristo, como Sustituto y Ejemplo. Esta fe que recibe la salvación, viene a través del poder de la Palabra y es el don de la gracia de Dios. Por medio de Cristo somos justificados, adoptados como hijos e hijas de Dios y libertados del dominio del pecado. Por medio del Espíritu, nacemos de nuevo y somos justificados.; el Espíritu renueva nuestra mente, escribe la ley de amor de Dios en nuestro corazón y se nos da el poder de vivir una vida santa. Permaneciendo en Él, llegamos a ser participantes de la naturaleza divina y tenemos la seguridad de la salvación, ahora y en el Juicio.\n\n2 Corintios 5:17-21; Juan 3:16; Gálatas 1:4; Gálatas 4:4-7; Tito 3:3-7; Juan 16:8; Gálatas 3:13-14; 1 Pedro 2:21-22; Romanos 10:17; Lucas 17:5; Marcos 9:23-24; Efesios 2:5-10; Romanos 3:21-26; Colosenses 1:13-14; Romanos 8:14-17; Gálatas 3:26; Juan 3:3-8; 1 Pedro 1:23; Romanos 12:2; Hebreos 8:7-12; Ezequiel 36:25-27; 2 Pedro 1:3-4; Romanos 8:1-4; Romanos 5:6-10.",
         @"section" : @2,
         @"index" : @2,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Creciendo en Cristo",
         @"content" : @"Por su muerte en la cruz Jesús triunfó sobre las fuerzas del mal. Aquél que subyugó los espíritus demoníacos durante su ministerio terrenal ha quebrantado su poder y aseguró su destino final. La victoria de Jesús nos da victoria sobre las fuerzas del mal que aún buscan controlarnos, mientras caminamos con él en paz, gozo y la seguridad de su amor. Ahora el Espíritu Santo mora en nosotros y nos da fortaleza. Continuamente comprometidos con Jesús como nuestro Salvador y Señor, somos liberados de las cargas de nuestros actos pasados. Ya no moramos más en la oscuridad, miedo de los poderes malignos, ignorancia y el sinsentido de nuestra anterior forma de vivir. En esta nueva libertad en Jesús, somos llamados a crecer en la semejanza de su carácter, comunicándonos cada día con Él en oración, alimentándonos de su Palabra, meditando en ella y en su providencia, cantando alabanzas, reuniéndonos para adorar, y participando en la misión de la Iglesia. Mientras nos damos a nosotros mismos en amoroso servicio hacia los que nos rodean y testimoniando acerca de su Salvación, su presencia constante con nosotros a través del Espíritu transforma cada momento y cada tarea en una experiencia espiritual.\n\nSalmo 1:1-2; Salmo 23:4; Salmo 77:11-12; Colosenses 1:13-14; Colosenses 2:6, 14, 15; Lucas 10:17-20; Efesios 5:19-20; Efesios 6:12-18; 1 Tesalonicenses 5:23; 2 Pedro 2:9; 2 Pedro 3:18; 2 Corintios 3:17-18; Filipenses 3:7-14; 1 Tesalonicenses 5:16-18; Mateo 20:25-28; Juan 20:21; Gálatas 5:22-25; Romanos 8:38-39; 1 Juan 4:4; Hebreos 10:25.",
         @"section" : @3,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Iglesia",
         @"content" : @"La Iglesia es la comunidad de creyentes que confiesan a Jesucristo como Señor y Salvador. En continuidad con el pueblo de Dios en los tiempos del Antiguo Testamento, somos llamados a salir del mundo; y nos unimos unimos para adorar, en fraternidad, para instrucción en la Palabra, para celebrar la Cena del Señor, para servir a toda la humanidad y para la proclamación mundial del Evangelio. La autoridad de la Iglesia deriva de Cristo, quien es la Palabra encarnada, y de las Escrituras, que son la Palabra escrita. La Iglesia es la familia de Dios, adoptados por Él como sus hijos e hijas. Sus miembros viven fundamentados en el nuevo pacto. La Iglesia es el cuerpo de Cristo, una comunidad de fe de quien Cristo mismo es la cabeza. La iglesia es la esposa por la que Cristo murió para poder santificarla y limpiarla. En su regreso triunfante, se la presentará a sí mismo como una iglesia gloriosa, la fiel de todas las épocas, la compra de su sangre, sin mancha ni arruga, sino santa y sin tacha.\n\nGénesis 12:3; Hechos 7:38; Efesios 4:11-15; Efesios 3:8-11; Mateo 28:19-20; Mateo 16:13-20; Mateo 18:18; Efesios 2:19-22; Efesios 1:22-23; Efesios 5:23-27; Colosenses 1:17-18.",
         @"section" : @3,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Remanente y su Misión",
         @"content" : @"La Iglesia universal se compone de todos los que verdaderamente creen en Cristo; pero, en los últimos días, en tiempo de extendida apostasía, ha sido llamado un remanente a fin de guardar los mandamientos de Dios y la fe de Jesús. Este remanente anuncia la llegada de la hora del Juicio, proclama la salvación por medio de Cristo y anuncia la proximidad de Su segundo advenimiento. Esta proclamación está simbolizada por los tres ángeles de Apocalipsis 14; coincide con la obra de juicio en el cielo, y trae como resultado el arrepentimiento y reforma sobre la Tierra. Cada creyente es llamado a tener una parte en esta testificación mundial.\n\nApocalipsis 12:17; Apocalipsis 14:6-12; Apocalipsis 18:1-4; 2 Corintios 5:10; Judas 1:3, 14; 1 Pedro 1:16-19; 2 Pedro 3:10-14; Apocalipsis 21:1-14.",
         @"section" : @3,
         @"index" : @2,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Unidad en el Cuerpo de Cristo",
         @"content" : @"La Iglesia es un cuerpo con muchos miembros, llamados de toda nación, tribu, lengua y pueblo. En Cristo somos una nueva creación; las diferencias de raza, cultura, educación, y nacionalidad, y las diferencias entre clases, ricos y pobres, hombre y mujer, no deben ser divisorias entre nosotros. Todos somos iguales en Cristo., quien a través de un Espíritu nos ha unido en una fraternidad con Él y los unos con los otros; tenemos que servir y ser servidos imparcialmente y sin reservas. Mediante la revelación de Jesucristo en las Escrituras, compartimos la misma fe y esperanza y extendemos un solo testimonio para todos. Esta unidad encuentra su fuente en la unidad del Dios trino y uno, que nos adoptó como Sus hijos.\n\nRomanos 12:4-5; 1 Corintios 12:12-14; Mateo 28:19-20; Salmo 133:1; 2 Corintios 5:16-17; Hechos 17:26-27; Gálatas 3:27-29; Colosenses 3:10-15; Efesios 4:14-16; Efesios 4:1-6; Juan 17:20-23.",
         @"section" : @3,
         @"index" : @3,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Bautismo",
         @"content" : @"Por el bautismo confesamos nuestra fe en la muerte y en la resurrección de Jesucristo y testimoniamos nuestra muerte al pecado y nuestro propósito de andar en novedad de vida. De este modo aceptamos a Cristo como nuestro Señor y Salvador, llegamos a pertenecer a su pueblo, y somos aceptados como miembros por Su Iglesia. El bautismo es un símbolo de nuestra unión con Cristo, el perdón de nuestros pecados y nuestra recepción del Espíritu Santo. Es por inmersión en agua y es contingente sobre una afirmación de fe en Jesús y evidencia de arrepentimiento del pecado. Tiene lugar tras la instrucción en las Santas Escrituras y la aceptación de sus enseñanzas.\n\nRomanos 6:1-6; Colosenses 2:12-13; Hechos 16:30-33; Hechos 22:16; Hechos 2:38; Mateo 28:19-20.",
         @"section" : @3,
         @"index" : @4,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Cena del Señor",
         @"content" : @"La Cena del Señor es una participación en los emblemas del cuerpo y de la sangre de Jesús, como expresión de fe en Él, nuestro Señor y Salvador. En esta experiencia de comunión Cristo está presente para fortalecer su pueblo. Al participar, gozosamente proclamamos la muerte del Señor hasta que regrese de nuevo. La preparación para la Cena incluye el examen de conciencia, arrepentimiento y confesión. El Maestro instituyó la ceremonia del lavamiento de pies para representar una limpieza renovada, para expresar la disposición de servir unos a otros en humildad semejante a la de Cristo, y para unir nuestros corazones en amor. El servicio de Comunión o Santa Cena está abierto a todos los cristianos creyentes.\n\n1 Corintios 10:16-17; 1 Corintios 11:23-30; Mateo 26:17-30; Apocalipsis 3:20; Juan 6:48-63; Juan 13:1-17.",
         @"section" : @3,
         @"index" : @5,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Dones y Minsterios Espirituales",
         @"content" : @"Dios confiere a todos los miembros de su Iglesia, en todas las épocas, dones espirituales que cada miembro debe emplear en amante ministerio por el bien común de la Iglesia y de la humanidad. Siendo otorgados por la actuación del Espíritu Santo, el cual distribuye a cada miembro como quiere, los dones proveen todas las aptitudes y ministerios que la Iglesia necesita para cumplir sus funciones divinamente ordenadas. De acuerdo con las Escrituras incluye tales ministerios como la fe, sanación, profecía, proclamación, enseñanza, administración, reconciliación, compasión, servicio abnegado, caridad para ayudar, y exhortación y aliento a las personas. Algunos miembros son llamados por Dios y dotados por el Espíritu para funciones reconocidas por la Iglesia en ministerios pastorales, evangélicos, apostólicos y de enseñanza. particularmente necesarios para capacitar a los miembros para el servicio, edificar a la iglesia para una madurez espiritual y fomentar la unidad de fe y el conocimiento de Dios. Cuando los miembros emplean esos dones espirituales como fieles mayordomos de la variada gracia de Dios, la iglesia es protegida de la destructiva influencia de la falsa doctrina, tiene un crecimiento que proviene de Dios y es edificada con fe y amor.\n\nRomanos 12:4-8; 1 Corintios 12:9-11, 27-28; Efesios 4:8, 11-16; Hechos 6:1-7; 1 Timoteo 3:1-13; 1 Pedro 4:10-11.",
         @"section" : @3,
         @"index" : @6,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Don de Profecía",
         @"content" : @"Uno de los dones del Espíritu Santo es el de profecía. Este don es una característica distintiva de la Iglesia remanente y fue manifestado en el ministerio de Ellen G. White. Como mensajera del Señor, sus escritos son una continua y autorizada fuente de verdad y proporcionan consuelo, guía, instrucción y corrección a la Iglesia. Sus escritos también dejan claro que la Biblia es la regla por la que debe ser probada toda enseñanza y experiencia.\n\nJoel 2:28-29; Hechos 2:14-21; Hebreos 1:1-3; Apocalipsis 12:17; Apocalipsis 19:10.",
         @"section" : @3,
         @"index" : @7,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Ley de Dios",
         @"content" : @"Los grandes principios de la Ley de Dios están incluidos en los Diez Mandamientos y ejemplificados en la vida de Cristo. Expresan el amor, la voluntad y los propósitos de Dios respecto la conducta y relaciones humanas, y son vinculantes a todas las personas de todas las épocas. Esos preceptos constituyen la base del pacto de Dios con su pueblo y la norma en el juicio de Dios. A través de la intervención del Espíritu Santo, los Mandamientos señalan el pecado y despiertan el sentido de necesidad de un Salvador. La Salvación es completamente por gracia y no por obras, pero el fruto de ella es la obediencia a los Mandamientos. Esta obediencia desarrolla el carácter cristiano y resulta en un sentido de bienestar. Es una evidencia de nuestro amor por el Señor y de nuestra preocupación por el prójimo. La obediencia de fe demuestra el poder de Cristo para transformar vidas, y por lo tanto fortalece el testimonio cristiano.\n\nÉxodo 20:1-17; Salmo 40:7-8; Mateo 22:36-40; Deuteronomio 28:1-14; Mateo 5:17-20; Hebreos 8:8-19; Juan 15:7-10; Efesios 2:8-10; 1 Juan 5:3; Romanos 8:3-4; Salmo 19:7-14.",
         @"section" : @4,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Sábado",
         @"content" : @"El bondadoso Creador, después de los seis días de la Creación, descansó el séptimo día e instituyó el Sábado para todo el mundo como recordativo de la Creación. El cuarto mandamiento de la inmutable Ley de Dios requiere la observancia de este séptimo día sábado como día de descanso, adoración y ministerio en armonía con las enseñanzas y prácticas de Jesús, el Señor del Sábado. El sábado es un día de agradable comunión con Dios y unos con otros. También es un símbolo de nuestra redención en Cristo, una señal de nuestra santificación, una demostración de nuestra lealtad, y un anticipo de nuestro futuro eterno en el reino de Dios. El sábado es una señal perpetua de su pacto eterno entre Él y su pueblo. La observancia gozosa de este santo tiempo de puesta de sol a puesta de sol o de tarde a tarde, es una celebración de los actos creativo y redentor de Dios.\n\nGénesis 2:1-3; Éxodo 20:8-11; Lucas 4:16; Isaías 56:5-6; Isaías 58:13-14; Mateo 12:1-12; Marcos 2:27-28; Éxodo 31:13-17; Ezequiel 20:12, 20; Deuteronomio 5:12-15; Hebreos 4:1-11; Levítico 23:32; Marcos 1:32.",
         @"section" : @4,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Mayordomía",
         @"content" : @"Somos mayordomos de Dios, quien nos ha encomendado el tiempo y las oportunidades, capacidades y posesiones, y las bendiciones de la Tierra y sus recursos. Reconocemos la propiedad divina por medio del fiel servicio a Él y a nuestros semejantes, y devolviendo diezmos y dando ofrendas para la proclamación de su Evangelio y para la manutención y el crecimiento de su iglesia. La mayordomía es un privilegio que nos ha dado Dios para crecer en amor y en victoria sobre el egoísmo y la codicia. El mayordomo se regocija en las bendiciones que sobrevienen a los demás como resultado de su fidelidad.\n\nGénesis 1:26-28; Génesis 2:15; 1 Crónicas 29:14; Hageo 1:3-11; Malaquías 3:8-12; 1 Corintios 9:9-14; Mateo 23:23; 2 Corintios 8:1-15; Romanos 15:26-27.",
         @"section" : @4,
         @"index" : @2,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Conducta Cristiana",
         @"content" : @"Somos llamados para ser un pueblo piadoso, que piensa, siente y actúa de acuerdo con los principios del Cielo. Para que el Espíritu recree en nosotros el carácter de nuestro Señor, nos involucramos sólo en aquellas cosas que producirán en nuestra vida pureza, salud y alegría semejantes a las de Cristo. Esto quiere decir que nuestra diversión y entretenimiento deberían cumplir la más alta norma del gusto y belleza cristianos. A la vez que reconocemos las diferencias culturales, nuestro vestido tiene que ser sencillo, modesto y pulcro, adecuándose aquellos cuya auténtica belleza no consiste en adorno externo sino en el incorruptible adorno de un espíritu tranquilo y afable. También significa que, dado que nuestro cuerpo es templo del Espíritu Santo, debemos cuidarlo de forma inteligente. Con ejercicio y descanso adecuados, debemos adoptar la dieta más saludable posible y abstenernos de alimentos inmundos identificados en las Escrituras. Dado que el uso del bebidas alcohólicas, el tabaco, y el uso irresponsable de drogas y narcóticos son dañinos para nuestra salud, debemos de abstenernos de ellos. En su lugar, debemos participar en cualquier cosa que eleve nuestros pensamientos y cuerpos a la disciplina de Cristo, quien desea nuestra salud completa, gozo y bienestar.\n\nRomanos 12:1-2; 1 Juan 2:6; Efesios 5:1-21; Filipenses 4:8; 2 Corintios 10:5; 2 Corintios 6:14-7:1; 1 Pedro 3:1-4; 1 Corintios 6:19-20; 1 Corintios 10:31; Levítico 11:1-47; 3 Juan 1:2.",
         @"section" : @4,
         @"index" : @3,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Matrimonio y Familia",
         @"content" : @"El matrimonio fue divinamente establecido en el Edén y confirmado por Jesús como unión vitalicia entre un hombre y una mujer, en amoroso compañerismo. Para el cristiano, el compromiso matrimonial es con Dios así como con el cónyuge, y solamente debe ser asumido entre parejas que comparten la misma fe. El amor mutuo, honor, respeto y responsabilidad son los elementos que edifican esta relación, que tiene que reflejar el amor, santidad, proximidad y permanencia de la relación entre Cristo y su Iglesia. Respecto al divorcio, Jesús enseñó que la persona que se divorcia del cónyuge, a no ser por causa de fornicación, y se casa con otro, comete adulterio. A pesar de que algunas relaciones familiares puedan no llegar al ideal, los cónyuges que se comprometen plenamente el uno al otro en Cristo, deben alcanzar la amorosa unidad con la guía del Espíritu Santo y los cuidados de la Iglesia. Dios bendice la familia y quiere que sus miembros se ayuden unos a otros hasta alcanzar completa madurez. Los padres deben educar sus hijos paraa amar al Señor y obedecerle. Por su ejemplo y sus palabras tienen que enseñarles que Cristo disciplina con amor, siempre tierno y cariñoso, quien desea que se conviertan en miembros de su cuerpo, la familia de Dios. Incrementar la unión familiar es uno de los cometidos de l mensaje final del Evangelio.\n\nGénesis 2:18-25; Mateo 19:3-9; Juan 2:1-11; 2 Corintios 6:14; Efesios 5:21-33; Mateo 5:31-32; Marcos 10:11-12; Lucas 16:18; 1 Corintios 7:10-11; Éxodo 20:12; Efesios 6:1-4; Deuteronomio 6:5-9; Proverbios 22:6; Malaquías 4:5-6.",
         @"section" : @4,
         @"index" : @4,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Ministerio de Cristo en el Santuario Celestial",
         @"content" : @"Hay un santuario en el Cielo, el tabernáculo verdadero que levantó el Señor y no el hombre. En él, Cristo intercede en nuestro favor, haciendo accesibles a los creyentes los beneficios de su sacrificio expiatorio ofrecido una vez para todos en la cruz. Él es nuestro gran Sumo Sacerdote y comenzó su ministerio intercesor en ocasión de su ascensión. En 1844, a final del período profético de los 2.300 días, inició la segunda y última fase de su ministerio expiatorio. Es una labor de juicio investigador que forma parte de la disposición final de todo pecado, tipificado por la purificación del antiguo santuario hebreo en el día de la Expiación. En aquel servicio tipo el santuario era purificado con la sangre de sacrificios animales, pero las cosas celestiales son purificadas con el sacrificio perfecto de la sangre de Jesús. El juicio investigador revela a las inteligencias celestiales quiénes de entre los muertos que duermen en Cristo y por lo tanto, en Él, son juzgados dignos de tener parte en la primera resurrección. También se hace manifiesto quiénes, de entre los vivos, están morando en Cristo, guardando los mandamientos de Dios y la fe de Jesús, y en Él, por lo tanto, están preparados para ser trasladados a su reino eterno. Este juicio vindica la justicia de Dios al salvar a aquellos que creen en Jesús. Declara que aquellos que han permanecido fieles a Dios recibirán su reino. La culminación de este ministerio de Cristo señalará el fin del tiempo de gracia para los seres humanos, antes del segundo advenimiento.\n\nHebreos 8:1-5; Hebreos 4:14-16; Hebreos 9:11-28; Hebreos 10:19-22; Hebreos 1:3; Hebreos 2:16-17; Daniel 7:9-27; Daniel 8:13-14; Daniel 9:24-27; Números 14:34; Ezequiel 4:6; Levítico 16; Apocalipsis 14:6-7; Apocalipsis 20:12; Apocalipsis 14:12; Apocalipsis 22:12.",
         @"section" : @5,
         @"index" : @0,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Segunda Venida de Cristo",
         @"content" : @"La segunda venida de Cristo es la bendita esperanza de la Iglesia, el gran clímax del Evangelio. La venida del Salvador será literal, personal, visible y global. Cuando Él regrese, los muertos justos resucitarán, y junto a los vivos justos serán glorificados y tomados a los cielos, pero los injustos morirán. El casi completo cumplimiento de la mayoría de profecías, junto con la presente condición del mundo, indican que la venida de Cristo es inminente. El momento de ese evento no ha sido revelado, y por lo tanto se nos exhorta a estar preparados en todo momento.\n\nTito 2:13; Hebreos 9:28; Juan 14:1-3; Hechos 1:9-11; Mateo 24:14; Apocalipsis 1:7; Mateo 24:43-44; 1 Tesalonicenses 4:13-18; 1 Corintios 15:51-54; 2 Tesalonicenses 1:7-10; 2 Tesalonicenses 2:8; Apocalipsis 14:14-20; Apocalipsis 19:11-21; Mateo 24; Marcos 13; Lucas 21; 2 Timoteo 3:1-5; 1 Tesalonicenses 5:1-6.",
         @"section" : @5,
         @"index" : @1,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"Muerte y Resurercción",
         @"content" : @"La paga del pecado es la muerte. Pero Dios, el único que es inmortal, concederá vida eterna a sus redimidos. Hasta aquel día, la muerte es un estado inconsciente para todas las personas. Cuando Cristo, quien es nuestra vida, aparezca, los justos resucitados y los justos vivos serán glorificados y tomados para encontrarse con su Señor. La segunda resurrección, la resurrección de los injustos, tendrá lugar mil años después.\n\nRomanos 6:23; 1 Timoteo 6:15-16; Eclesiastés 9:5-6; Salmo 146:3-4; Juan 11:11-14; Colosenses 3:4; 1 Corintios 15:51-54; 1 Tesalonicenses 4:13-17; Juan 5:28-29; Apocalipsis 20:1-10.",
         @"section" : @5,
         @"index" : @2,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"El Milenio y el Fin del Pecado",
         @"content" : @"El milenio es el reinado de mil años de Cristo con sus santos en el Cielo entre la primera y la segunda resurrección. Durante este tiempo serán juzgados los impíos muertos; la Tierra estará completamente desolada, sin habitantes humanos vivos, aunque estará ocupada por Satanás y sus ángeles. Al fin de ese período, Cristo con sus Santos y la Santa Ciudad descenderán del cielo a la Tierra. Los impíos muertos serán entonces resucitados y, con Satanás y sus ángeles, cercarán la ciudad; pero el fuego de Dios los consumirá y purificará la Tierra. El Universo será liberado para siempre del pecado y de los pecadores.\n\nApocalipsis 20; 1 Corintios 6:2-3; 2 Pedro 3:7; Jeremías 4:23-26; Apocalipsis 21:1-5; Malaquías 4:1; Ezequiel 28:18-19.",
         @"section" : @5,
         @"index" : @3,
         }];
        
        [ORM factory:@"Belief" withValues:@{
         @"title" : @"La Nueva Tierra",
         @"content" : @"En la Nueva Tierra, en que habita la justicia, Dios proveerá un hogar eterno para los redimidos y un medio ambiente perfecto para la vida eterna, amor, gozo y aprendizaje en su presencia. Porque allí mismo morará Dios con su pueblo, y el sufrimiento y la muerte ya habrán pasado. La gran controversia habrá llegado a su fin, y no habrá más pecado. Todas las cosas, animadas e inanimadas, declararán que Dios es amor; y Él reinará para siempre. Amén.\n\n2 Pedro 3:13; Isaías 35; Isaías 65:17-25; Mateo 5:5; Apocalipsis 21:1-7; Apocalipsis 22:1-5; Apocalipsis: 11:15.",
         @"section" : @5,
         @"index" : @4,
         }];
        
        
    }
}
@end
