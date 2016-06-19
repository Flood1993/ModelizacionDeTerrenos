import peasy.*;

PeasyCam cam;

double errorAltura = 25; //Error sobre el que consideramos o no que puntos pueden ser borrados mediante la 8 vecindad. (si sus vecinos están en (x-error, x+error). Valor aconsejado 25
int distanciaEntrePuntos = 100; //Distancia a la que consideramos que están los puntos de la malla regular. Valor aconsejado 100
int numeroDeColumnas; //Variable auxiliar que se inicializa al llamar a calcular()
int numeroDeFilas; //Variable auxiliar que se inicializa al llamar a calcular()
Arista[] aristas; //Contendrá las aristas una vez hecho el DCEL
Cara[] caras; //Contendrá las caras una vez hecho el DCEL

/*
----- CONTROLES DE LA CÁMARA 3D -----
La cámara esta centrada sobre un punto.

Click izquierdo: Girar la cámara alrededor del punto
Click derecho: Alejar o acercar la cámara al punto
Click izquierdo + click derecho (manteniendo ambos): Desplazar el punto, es decir, mover la cámara.

NOTA: Si colocas la cámara de modo que el terreno se vea de lado (no desde arriba), puedes cambiar la altura de la cámara con ambos clicks.

----- FUNCIONES DE INTERES -----

p.dibujar2D();
    Imprime la triangulación de DELONE de los puntos en 2D (aún así podemos mover la cámara en el espacio tridimensional).
p.dibujar3D();
    Imprime la triangulación de DELONE de los puntos en 3D.
p.perfilAlturasTrayectoria(double x1, double y1, double x2, double y2);
    Dadas 4 coordenadas de 2 puntos X(x1,y1) Y(x2,y2), muestra el perfil de alturas para llegar de uno a otro en linea recta.
p.caminoGota(double x, double y);
    Dadas unas coordenadas (x,y) de la posición de una gota en la malla triangular 3D, muestra el camino de
      descenso de ésta, bien hasta que se estanque o hasta que se salga de la malla en 3D. Si la gota coincide con un punto de la malla, calcula 4 trayectorias en X.
    Nótese que el camino lo pinta en blanco.
p.curvasDeNivel2D(double altura);
    Dada una altura, muestra en 2D las curvas de nivel a esa altura.
p.curvasDeNivel3D(double altura);
    Dada una altura, muestra en 3D las curvas de nivel a esa altura.
    
Se recomienda combinar dibujar2D() y dibujar3D() dependiendo de lo que queramos visualizar (excepto para p.perfilAlturasTrayectoria(...);)
con la función en sí para tener el terreno visualizado y además lo que nos sea de interés.
*/

//NOTA: No tocar el setup. Todo lo que imprime es en 3D, aunque sea la representación en 2D, para poder mover la cámara.
void setup()
{
  size(displayWidth-50, displayHeight-100, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);
  Prueba p = new Prueba();

  p.calcular(); //Calcular carga todos los valores del DCEL para poder trabajar con el terreno
}

void draw()
{
  Prueba p = new Prueba();
  background(204);
  
  //p.perfilAlturasTrayectoria(0,20,6468,3458);
  //p.perfilAlturasTrayectoria(1688,2474.5,30,31);
  //Calcula el perfil de alturas de una punta a otra de la malla
  //p.perfilAlturasTrayectoria(0,0,10000,10000);

  //p.dibujar2D();
  //p.dibujar3D();
  
  //p.curvasDeNivel2D(870);
  //p.curvasDeNivel3D(870);
  //p.curvasDeNivel3D(890);
  //p.curvasDeNivel3D(910);
  //p.curvasDeNivel3D(930);
  //p.curvasDeNivel3D(950);
  //p.caminoGota(4156, 1134);
  
  //p.caminoGota(30,30);
  //p.caminoGota(230,1240);
  //p.caminoGota(230,740);
  //p.caminoGota(230,540);
  //p.caminoGota(230,240);
  //p.caminoGota(1345,5000);
  //Caso especial de camino gota, donde la gota esta en un punto de la malla. Lo que hace el metodo es pintar 4 caminos diferentes, como si hubiera 4 gotas en X alrededor del punto
  //p.caminoGota(1000,1000);
  
}



public class Prueba
{
  //metodo que dada una altura, calcula las curvas de nivel a esa altura y los dibuja. (2D)
  /*
  FUNCIONAMIENTO:
  Para cada arista, miramos si existe un punto en esa arista con la altura pasada como parámetro. Si existe, quiere decir que en esa arista corta la altura Z.
  Por tanto, para dibujar la curva de nivel, nos fijamos en 4 aristas, que serán las candidatas a que la curva de nivel también las corte: 
  la siguiente, la anterior, y la siguiente y la anterior de la gemela (es decir, un rombo cuya diagonal es la arista encontrada). Si para alguna de esas
  también corta la altura Z, dibujamos un segmento que une dichos puntos (en 2D).
  */
  public void curvasDeNivel2D(double z)
  {
    stroke(0);
    strokeWeight(4);
    
    //naristas contiene el numero total de aristas
    int naristas = 0;
    for (int i = 0; i < aristas.length; i++)
    {
      if (aristas[i] == null) {}
      else { 
        naristas++;
      }
    }
    
    for (int i = 0; i < naristas; i++)
    {
      //Si para cada arista, existe un punto, miramos las 4 aristas de alrededor
      if (existePunto(aristas[i], z))
      {
        Punto p1 = puntoAltura(aristas[i], z);
        if (existePunto(aristas[i].siguiente, z))
        {
          Punto p2 = puntoAltura(aristas[i].siguiente, z);
          line((float) p1.x, (float) p1.y, 0, (float) p2.x, (float) p2.y, 0);
        }
        if (existePunto(aristas[i].anterior, z))
        {
          Punto p2 = puntoAltura(aristas[i].anterior, z);
          line((float) p1.x, (float) p1.y, 0, (float) p2.x, (float) p2.y, 0);
        }
        if (existePunto(aristas[i].gemela.siguiente, z))
        {
          Punto p2 = puntoAltura(aristas[i].gemela.siguiente, z);
          line((float) p1.x, (float) p1.y, 0, (float) p2.x, (float) p2.y, 0);
        }
        if (existePunto(aristas[i].gemela.anterior, z))
        {
          Punto p2 = puntoAltura(aristas[i].gemela.anterior, z);
          line((float) p1.x, (float) p1.y, 0, (float) p2.x, (float) p2.y, 0);
        }
      }
    }
  }
  
  //metodo que dada una altura, calcula las curvas de nivel a esa altura y los dibuja. (3D)
  /*
  FUNCIONAMIENTO:
  Para cada arista, miramos si existe un punto en esa arista con la altura pasada como parámetro. Si existe, quiere decir que en esa arista corta la altura Z.
  Por tanto, para dibujar la curva de nivel, nos fijamos en 4 aristas, que serán las candidatas a que la curva de nivel también las corte: 
  la siguiente, la anterior, y la siguiente y la anterior de la gemela (es decir, un rombo cuya diagonal es la arista encontrada). Si para alguna de esas
  también corta la altura Z, dibujamos un segmento que une dichos puntos (en 3D).
  */
  public void curvasDeNivel3D(double z)
  {
    stroke(0);
    strokeWeight(4);
    
    //naristas contiene el numero total de aristas
    int naristas = 0;
    for (int i = 0; i < aristas.length; i++)
    {
      if (aristas[i] == null) {}
      else { 
        naristas++;
      }
    }
    
    for (int i = 0; i < naristas; i++)
    {
      //Si para cada arista, existe un punto, miramos las 4 aristas de alrededor
      if (existePunto(aristas[i], z))
      {
        Punto p1 = puntoAltura(aristas[i], z);
        if (existePunto(aristas[i].siguiente, z))
        {
          Punto p2 = puntoAltura(aristas[i].siguiente, z);
          line((float) p1.x, (float) p1.y, (float) z, (float) p2.x, (float) p2.y, (float) z);
        }
        if (existePunto(aristas[i].anterior, z))
        {
          Punto p2 = puntoAltura(aristas[i].anterior, z);
          line((float) p1.x, (float) p1.y, (float) z, (float) p2.x, (float) p2.y, (float) z);
        }
        if (existePunto(aristas[i].gemela.siguiente, z))
        {
          Punto p2 = puntoAltura(aristas[i].gemela.siguiente, z);
          line((float) p1.x, (float) p1.y, (float) z, (float) p2.x, (float) p2.y, (float) z);
        }
        if (existePunto(aristas[i].gemela.anterior, z))
        {
          Punto p2 = puntoAltura(aristas[i].gemela.anterior, z);
          line((float) p1.x, (float) p1.y, (float) z, (float) p2.x, (float) p2.y, (float) z);
        }
      }
    }
  }
  
  //metodo que dice si existe un punto con altura z en la arista a
  /*
  FUNCIONAMIENTO:
  Sacamos la ecuación paramétrica del vector que representa la arista. t es la constante por la que hay que multiplicar para llegar al punto de la recta con altura z.
  Si z está en [0,1], quiere decir que el punto pertenece a la arista. En caso contrario, no.
  */
  public boolean existePunto(Arista arista, double z)
  {
    double a = arista.origen.x;
    double b = arista.origen.y; 
    double c = arista.origen.z; 
    double d = arista.siguiente.origen.x - a; 
    double e = arista.siguiente.origen.y - b; 
    double f = arista.siguiente.origen.z - c;
     
    double t = (z-c)/f;
     
    if (t >= 0 && t <= 1)
    {
      return true;
    }
    
    return false;
  }
  
  //metodo que devuelve un punto con altura z en la arista a
  /*
  FUNCIONAMIENTO:
  Análogo al método existePunto(...), solo que devuelve el punto en vez de decir si existe o no.
  */
  public Punto puntoAltura(Arista arista, double z)
  {
    Punto p = new Punto(0,0,0);
    
    double a = arista.origen.x;
    double b = arista.origen.y; 
    double c = arista.origen.z; 
    double d = arista.siguiente.origen.x - a; 
    double e = arista.siguiente.origen.y - b; 
    double f = arista.siguiente.origen.z - c;
     
    double t = (z-c)/f;
     
    if (t >= 0 && t <= 1)
    {
      p = new Punto(a + d*t, b + e*t, c + f*t);
    }
    
    return p;
  }
  
  //metodo que dados dos puntos(de dentro de la malla o del borde), hace un perfil de alturas desde el punto origen al destino en linea recta. (2D)
  /*
  FUNCIONAMIENTO:
  Primero, si saebmos que los datos van a dar problemas, los ajustamos para que no.
  Después, lo que hacemos es encontrar la cara a la que pertenece cada punto. Mientras no estén en la misma, lo que hay que hacer es calcular un vector
  que sea la dirección para ir de P a Q. Después, vamos almacenando los diferentes puntos visitados, y moviendonos por la cara de p en la direccion PQ
  hasta que cambiemos de cara (cada vez que cambiamos almacenamos el punto, para saber la altura). Sabemos que por ir siempre en la misma dirección,
  terminaremos llegando a la cara de Q. Una vez hemos terminado, pintamos todo el camino y además hay que dibujar un último cambio de alturas que es
  del punto Pn de la cara Q, a Q.
  */
  public void perfilAlturasTrayectoria(double px, double py, double qx, double qy)
  {
    stroke(0);
    strokeWeight(1);
    
    if (px <= 0)
      px = 1;
    if (py <= 0)
      py = 1;
    if (qx <= 0)
      qx = 1;
    if (qy <= 0)
      qy = 1;
    if (px >= (numeroDeColumnas-1) * distanciaEntrePuntos)
      px = (numeroDeColumnas-1) * distanciaEntrePuntos;
    if (qx >= (numeroDeColumnas-1) * distanciaEntrePuntos)
      qx = (numeroDeColumnas-1) * distanciaEntrePuntos;
    if (py >= (numeroDeFilas-1) * distanciaEntrePuntos)
      py = (numeroDeFilas-1) * distanciaEntrePuntos - 1;
    if (qy >= (numeroDeFilas-1) * distanciaEntrePuntos)
      qy = (numeroDeFilas-1) * distanciaEntrePuntos - 1;
    
    if (px%distanciaEntrePuntos == 0 && py%distanciaEntrePuntos == 0)
    {
      px = px+1;
     // py = py+1;
    }
    if (qx%distanciaEntrePuntos == 0 && qy%distanciaEntrePuntos == 0)
    {
      qx = qx+1;
      //qy = qy+1;
    }
    if (px%distanciaEntrePuntos - 1 == 0 && py%distanciaEntrePuntos - 1 == 0 && qx%distanciaEntrePuntos - 1 == 0 && qy%distanciaEntrePuntos - 1 == 0)
      px = px+1;
      
    int m = (int) ((qy - py) / (qx - px));
    int n = (int) (py - m*px);
    if (qx > px)
    {
      for (int i = (int) px; i <= qx; i++)
        {
          int y = m*i + n;
          if (i % distanciaEntrePuntos == 0 && y % distanciaEntrePuntos == 0)
          {
            px = px+1;
            break;
          }
        }
    }
    
    if (qx < px)
    {
      for (int i = (int) px; i  >= qx; i--)
        {
          int y = m*i + n;
          if (i % distanciaEntrePuntos == 0 && y % distanciaEntrePuntos == 0)
          {
            px = px-1;
            break;
          }
        }
    }
    
    Punto[] puntos = new Punto[aristas.length];

    Punto p = new Punto(0,0,0);
    Punto q = new Punto(0,0,0);

    Cara carap = null;
    Cara caraq = null;

    //nelms contiene el numero total de caras
    int nelms = 0;
    for (int i = 0; i < caras.length; i++)
    {
      if (caras[i] == null) {}
      else { 
        nelms++;
      }
    }
    
    boolean setP = false;
    boolean setQ = false;
    
    //Actualizamos las caras de p y q e inicializamos los puntos
    for (int i = 1; i < nelms; i++)
    {
      if (pertenece(px, py, caras[i]) && !setP)
      {
        carap = caras[i];
        p.x = px;
        p.y = py;
        p.z = coordZ(px, py, carap);
        setP = true;
      }
      if (pertenece(qx, qy, caras[i]) && !setQ)
      {
        caraq = caras[i];
        q.x = qx;
        q.y = qy;
        q.z = coordZ(qx, qy, caraq);
        setQ = true;
      }
    }
    
    int posAGuardar = 0;
    puntos[posAGuardar] = p; posAGuardar++;
    
    Arista arInterseccion = interseccionPrimeraVez(p, q.x, q.y, q.z, carap);
    p = puntoInterseccion(p.x, p.y, q.x, q.y, arInterseccion.origen.x, arInterseccion.origen.y, arInterseccion.siguiente.origen.x, arInterseccion.siguiente.origen.y, carap);
    carap = arInterseccion.gemela.cara;
    puntos[posAGuardar] = p; posAGuardar++;
    
    while (carap != caraq)
    {
      arInterseccion = arInterseccion.gemela;
      arInterseccion = interseccionSegundaVez(p, q.x, q.y, q.z, carap, arInterseccion);
            
      p = puntoInterseccion(p.x, p.y, q.x, q.y, arInterseccion.origen.x, arInterseccion.origen.y, arInterseccion.siguiente.origen.x, arInterseccion.siguiente.origen.y, carap);
      
      Cara caraaux = carap;
      carap = arInterseccion.gemela.cara;
      
      if (carap == caraaux)
      {
        break;
      }
      
      if (carap == caras[0])
      {
        line(0,0,0,500,500,0);
        break;
      }
      
      puntos[posAGuardar] = p; posAGuardar++;
      
    }
    
    double total = 0;
    
    for (int i = 1; i < posAGuardar; i++)
    {
      double nextx = sqrt( (float) ((puntos[i].x-puntos[i-1].x)*(puntos[i].x-puntos[i-1].x) + (puntos[i].y-puntos[i-1].y)*(puntos[i].y-puntos[i-1].y)) );
      line((float) (total) , (float) (puntos[i-1].z), 0, (float) (total + nextx), (float) (puntos[i].z), 0);
      total += nextx;
    }
    line((float) (total) , (float) (p.z), 0, (float) (total + 50), (float) (q.z), 0);
    
  }

  //metodo que dado un punto (x,y) calcula su Z y dibuja la trayectoria de caída de una gota en esa posición de la maya triangular, hasta que se salga o se estanque (lo dibuja en 3D)
  /*
  FUNCIONAMIENTO:
  Primero, comprobamos que los datos pasados sean "buenos", si no, los alteramos.
  Después, calculamos la cara a la que pertenece el punto, y sabiendo el vector normal del plano de esa cara, sabemos que la gota caerá en la direccion (x,y) del vector
  normal, pero no sabemos la dirección Z, por lo que la calculamos nosotros metiendo el vector normal en el plano. Calculamos el punto de intersección de esa dirección
  con la arista del plano con la que corte. Una vez localizado el punto, lo almacenamos y nos vamos a la siguiente cara. Repetimos el proceso hasta que la gota caiga al
  plano del que venimos, ya que esto significa que ahora habrá que desplazarse sólo por aristas.
  Lo que hacemos entonces es mirar para la primera arista, hacia que lado va. Ésto nos dará un único vértice. Luego, para ese vértice, vamos mirando los vecinos y eligiendo
  a cual de ellos cae la gota. Si todos son de altura superior al actual, la gota se queda estancada definitivamente. 
  Si la gota llega a alguna arista de la cara exterior, no sabemos que hará, asi que terminamos también el proceso.
  */
  public void caminoGota(double x, double y)
  {
    stroke(255);
    strokeWeight(4);
    
    if (x <= 0)
      x = 1;
    if (x >= (numeroDeColumnas-1) * distanciaEntrePuntos)
      x = ((numeroDeColumnas-1) * distanciaEntrePuntos) - 1;
    if (y <= 0)
      y = 1;
    if (y >= (numeroDeFilas-1) * distanciaEntrePuntos)
      y = ((numeroDeFilas-1) * distanciaEntrePuntos) - 1;
    
    //Si la gota está en un punto de la malla triangular, calculamos 4 caminos posibles.
    if (x%distanciaEntrePuntos == 0 && y%distanciaEntrePuntos == 0)
    {
      caminoGota(x-1,y-1);
      caminoGota(x-1,y+1);
      caminoGota(x+1,y-1);
      caminoGota(x+1,y+1);
    }
    else
    {
    Punto p = crearPunto(x, y, caras);

    //nelms contiene el numero total de caras
    int nelms = 0;
    for (int i = 0; i < caras.length; i++)
    {
      if (caras[i] == null) {
      }
      else { 
        nelms++;
      }
    }

    Cara caraActual = caras[0];
    boolean puedoSeguir = true;
    Arista aristaUltimoCambio = null;

    double xnext = 0;
    double ynext = 0;
    double znext = 0;

    //Si es la primera vez, hay que buscar la cara
    for (int i = 1; i < nelms; i++)
    {
      if (pertenece(p.x, p.y, caras[i]))
      {
        caraActual = caras[i];
        /*
        double x1 = caras[i].arista.origen.x;
        double y1 = caras[i].arista.origen.y;
        double z1 = caras[i].arista.origen.z;

        double x2 = caras[i].arista.anterior.origen.x;
        double y2 = caras[i].arista.anterior.origen.y;
        double z2 = caras[i].arista.anterior.origen.z;

        double x3 = caras[i].arista.siguiente.origen.x;
        double y3 = caras[i].arista.siguiente.origen.y;
        double z3 = caras[i].arista.siguiente.origen.z;

        double D1 = (y2-y1)*(z3-z1) - (z2-z1)*(y3-y1);
        double D2 = (x2-x1)*(z3-z1) - (z2-z1)*(x3-x1);
        double D3 = (x2-x1)*(y3-y1) - (y2-y1)*(x3-x1);

        //variables del plano de la forma ax + by + cz + d = 0
        double a = D1;
        double b = 0 - D2;
        double c = D3;
        double d = y1*D2 - D1*x1 - z1*D3;

        //notese que (a,b,c) es el vector normal al plano. Si miramos desde arriba, el vector normal "coincide" con su proyeccion, asi que hay que jugar con la coordenada Z

        double dirx = a + p.x;
        double diry = b + p.y;
        double dirz = coordZ(dirx, diry, caras[i]);

        Arista arInterseccion = interseccionPrimeraVez(p, dirx, diry, dirz, caraActual);
        aristaUltimoCambio = arInterseccion.gemela;

        Punto aux = puntoInterseccion(p.x, p.y, dirx, diry, arInterseccion.origen.x, arInterseccion.origen.y, arInterseccion.siguiente.origen.x, arInterseccion.siguiente.origen.y, caraActual);
        line((float) p.x, (float) p.y, (float) p.z, (float) aux.x, (float) aux.y, (float) aux.z);

        caraActual = arInterseccion.cara;
        if (caraActual == caras[0])
        {
          puedoSeguir = false;
        }

        p.x = aux.x;
        p.y = aux.y;
        p.z = aux.z;
*/
        break;
      }
    }

    boolean porAristas = false;

    //Si no es la primera vez, hacemos para esa cara el punto, y vamos moviendonos. Si por la siguiente volvemos a la anterior, quiere decir que es hora de moverse por las aristas.
    while (puedoSeguir)
    {
      //si es la cara de fuera, no puedo seguir
      if (caraActual == caras[0])
      {
        puedoSeguir = false;
        break;
      }

      double x1 = caraActual.arista.origen.x;
      double y1 = caraActual.arista.origen.y;
      double z1 = caraActual.arista.origen.z;

      double x2 = caraActual.arista.anterior.origen.x;
      double y2 = caraActual.arista.anterior.origen.y;
      double z2 = caraActual.arista.anterior.origen.z;

      double x3 = caraActual.arista.siguiente.origen.x;
      double y3 = caraActual.arista.siguiente.origen.y;
      double z3 = caraActual.arista.siguiente.origen.z;

      double D1 = (y2-y1)*(z3-z1) - (z2-z1)*(y3-y1);
      double D2 = (x2-x1)*(z3-z1) - (z2-z1)*(x3-x1);
      double D3 = (x2-x1)*(y3-y1) - (y2-y1)*(x3-x1);

      //variables del plano de la forma ax + by + cz + d = 0
      double a = D1;
      double b = 0 - D2;
      double c = D3;
      double d = y1*D2 - D1*x1 - z1*D3;

      //notese que (a,b,c) es el vector normal al plano. Si miramos desde arriba, el vector normal "coincide" con su proyeccion, asi que hay que jugar con la coordenada Z

      double dirx = p.x + a;
      double diry = b + p.y;
      double dirz = coordZ(dirx, diry, caraActual);

      //si me voy por donde he venido, cambio a moverme por las aristas
      if (interseccionPrimeraVez(p, dirx, diry, dirz, caraActual) == aristaUltimoCambio)
      {
        puedoSeguir = false;
        porAristas = true;
        break;
      }

      Arista arInterseccion = interseccionSegundaVez(p, dirx, diry, dirz, caraActual, aristaUltimoCambio);
      aristaUltimoCambio = arInterseccion.gemela;

      Punto aux = puntoInterseccion(p.x, p.y, dirx, diry, arInterseccion.origen.x, arInterseccion.origen.y, arInterseccion.siguiente.origen.x, arInterseccion.siguiente.origen.y, caraActual);
      line((float) p.x, (float) p.y, (float) p.z, (float) aux.x, (float) aux.y, (float) aux.z);

      p.x = aux.x;
      p.y = aux.y;
      p.z = aux.z;

      caraActual = arInterseccion.gemela.cara;
    }

    if (!arinterior(aristaUltimoCambio) || !arinterior(aristaUltimoCambio.gemela))
      porAristas = false;

    if (porAristas)
    {
      if (aristaUltimoCambio.origen.z > aristaUltimoCambio.gemela.origen.z)
      {
        line((float) p.x, (float) p.y, (float) p.z, (float) aristaUltimoCambio.gemela.origen.x, (float) aristaUltimoCambio.gemela.origen.y, (float) aristaUltimoCambio.gemela.origen.z);
        p.x = aristaUltimoCambio.gemela.origen.x;
        p.y = aristaUltimoCambio.gemela.origen.y;
        p.z = aristaUltimoCambio.gemela.origen.z;

        if (aristaUltimoCambio.origen.x != p.x || aristaUltimoCambio.origen.y != p.y)
          aristaUltimoCambio = aristaUltimoCambio.gemela;
      }
      else
      {
        line((float) p.x, (float) p.y, (float) p.z, (float) aristaUltimoCambio.origen.x, (float) aristaUltimoCambio.origen.y, (float) aristaUltimoCambio.origen.z);
        p.x = aristaUltimoCambio.origen.x;
        p.y = aristaUltimoCambio.origen.y;
        p.z = aristaUltimoCambio.origen.z;

        if (aristaUltimoCambio.origen.x != p.x || aristaUltimoCambio.origen.y != p.y)
          aristaUltimoCambio = aristaUltimoCambio.gemela;
      }
    }

    while (porAristas)
    {
      Arista ultima = aristaUltimoCambio.anterior.gemela;
      double difAlturaMax = 0;
      double distanciaManhattanMax = 0;
      Arista porLaQueNosVamos = aristaUltimoCambio;

      while (ultima != aristaUltimoCambio)
      {
        if (!arinterior(ultima) || !arinterior(ultima.gemela))
        {
          porAristas = false;
          break;
        }

        distanciaManhattanMax = abs(aristaUltimoCambio.origen.x - ultima.siguiente.origen.x) + abs(aristaUltimoCambio.origen.y - ultima.siguiente.origen.y);
        double difAltura = aristaUltimoCambio.origen.z - ultima.siguiente.origen.z;
        double distanciaManhattan = abs(aristaUltimoCambio.origen.x - ultima.siguiente.origen.x) + abs(aristaUltimoCambio.origen.y - ultima.siguiente.origen.y);

        if (difAltura >= difAlturaMax)
        {
          difAlturaMax = difAltura;
          if (distanciaManhattanMax <= distanciaManhattan)
          {
            distanciaManhattanMax = distanciaManhattan;
            porLaQueNosVamos = ultima;
          }
        }

        ultima = ultima.anterior.gemela;
      }

      if (porLaQueNosVamos == aristaUltimoCambio)
      {
        porAristas = false;
        break;
      }

      line((float) aristaUltimoCambio.origen.x, (float) aristaUltimoCambio.origen.y, (float) aristaUltimoCambio.origen.z, (float) porLaQueNosVamos.siguiente.origen.x, (float) porLaQueNosVamos.siguiente.origen.y, (float) porLaQueNosVamos.siguiente.origen.z);

      aristaUltimoCambio = porLaQueNosVamos.gemela;
    }
    }
  }

  public double abs(double x)
  {
    if (x < 0)
      return 0-x;
    return x;
  }

  //Metodo que devuelve el punto de interseccion dadas dos rectas, sabiendo ya que es sobre la que necesitamos calcular (previamente usando el metodo interseccion)
  //Lo hayamos con las ecuaciones paramétricas, hayando la intersección.
  public Punto puntoInterseccion(double a, double b, double c, double d, double e, double f, double g, double h, Cara cara)
  {
    double t = ( ((c-a)*b + (d-b)*e - a*(d-b) - f*(c-a)) / ((h-f)*(c-a)-(d-b)*(g-e)) );

    Punto p = new Punto(e + (g-e)*t, f + (h-f)*t, coordZ(e + (g-e)*t, f + (h-f)*t, cara));

    return p;
  }

  //Devuelve la arista con la que intersecciona la recta dada por un punto y una direccion
  //Para saber si dos vectores se cortan, si el vector uno es el vector AB y el segundo CD, ambos se cortaran si las orientaciones de los triángulos
  //ABC, ABD son diferentes y también las de CDA CDB son diferentes. Comprobamos esta condición para las 3 aristas de la cara.
  public Arista interseccionPrimeraVez(Punto p, double dirx, double diry, double dirz, Cara cara)
  {
    double aristacaraorigenx = cara.arista.origen.x;
    double aristacaraorigeny = cara.arista.origen.y;

    double aristacarasiguientex = cara.arista.siguiente.origen.x;
    double aristacarasiguientey = cara.arista.siguiente.origen.y;

    double aristacaraanteriorx = cara.arista.anterior.origen.x;
    double aristacaraanteriory = cara.arista.anterior.origen.y;
    
    if (orientacion(p.x, p.y, dirx, diry, aristacaraorigenx, aristacaraorigeny) == 3)
      return cara.arista;
    if (orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey) == 3)
      return cara.arista.siguiente;
    if (orientacion(p.x, p.y, dirx, diry, aristacaraanteriorx, aristacaraanteriory) == 3)
      return cara.arista.anterior;

    if ( (orientacion(p.x, p.y, dirx, diry, aristacaraorigenx, aristacaraorigeny) != orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey)) &&
      (orientacion(aristacaraorigenx, aristacaraorigeny, aristacarasiguientex, aristacarasiguientey, p.x, p.y) != orientacion(aristacaraorigenx, aristacaraorigeny, aristacarasiguientex, aristacarasiguientey, dirx, diry) ) )
      return cara.arista;

    if ( (orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey) != orientacion(p.x, p.y, dirx, diry, aristacaraanteriorx, aristacaraanteriory)) &&
      (orientacion(aristacarasiguientex, aristacarasiguientey, aristacaraanteriorx, aristacaraanteriory, p.x, p.y) != orientacion(aristacarasiguientex, aristacarasiguientey, aristacaraanteriorx, aristacaraanteriory, dirx, diry) ) )
      return cara.arista.siguiente;

    return cara.arista.anterior;
  }
  
  //Devuelve la arista con la que intersecciona la recta dada por un punto y una direccion. Se le pasa como parametro una arista para saber que por ella no podemos volver
  //Igual que el método anterior, solo que ahora, además sabemos que el punto está en una arista, por lo que nos interesa que nos devuelva la arista por la que se va
  //pero ésta no puede ser por la que venimos.
  public Arista interseccionSegundaVez(Punto p, double dirx, double diry, double dirz, Cara cara, Arista ar)
  {
    double aristacaraorigenx = cara.arista.origen.x;
    double aristacaraorigeny = cara.arista.origen.y;

    double aristacarasiguientex = cara.arista.siguiente.origen.x;
    double aristacarasiguientey = cara.arista.siguiente.origen.y;

    double aristacaraanteriorx = cara.arista.anterior.origen.x;
    double aristacaraanteriory = cara.arista.anterior.origen.y;
    
    if (orientacion(p.x, p.y, dirx, diry, aristacaraorigenx, aristacaraorigeny) == 3 && cara.arista != ar)
      return cara.arista;
    if (orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey) == 3 && cara.arista.siguiente != ar)
      return cara.arista.siguiente;
    if (orientacion(p.x, p.y, dirx, diry, aristacaraanteriorx, aristacaraanteriory) == 3 && cara.arista.anterior != ar)
      return cara.arista.anterior;

    if ( (orientacion(p.x, p.y, dirx, diry, aristacaraorigenx, aristacaraorigeny) != orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey)) &&
      (orientacion(aristacaraorigenx, aristacaraorigeny, aristacarasiguientex, aristacarasiguientey, p.x, p.y) != orientacion(aristacaraorigenx, aristacaraorigeny, aristacarasiguientex, aristacarasiguientey, dirx, diry) ) && cara.arista != ar )
      return cara.arista;

    if ( (orientacion(p.x, p.y, dirx, diry, aristacarasiguientex, aristacarasiguientey) != orientacion(p.x, p.y, dirx, diry, aristacaraanteriorx, aristacaraanteriory)) &&
      (orientacion(aristacarasiguientex, aristacarasiguientey, aristacaraanteriorx, aristacaraanteriory, p.x, p.y) != orientacion(aristacarasiguientex, aristacarasiguientey, aristacaraanteriorx, aristacaraanteriory, dirx, diry) ) && cara.arista.siguiente != ar )
      return cara.arista.siguiente;

    return cara.arista.anterior;
  }

  //Devuelve 1 2 o 3 dependiendo del tipo de orientacion que tengan los 3 puntos (1->2->3) | 1 positiva 2 negativa 3 alineados
  public int orientacion(double ax, double ay, double bx, double by, double cx, double cy)
  {
    if ( (ax-cx)*(by-cy) - (ay-cy)*(bx-cx) > 0 )
      return 1;
    if ( (ax-cx)*(by-cy) - (ay-cy)*(bx-cx) < 0 )
      return 2;
    return 3;
  }

  //Metodo que dibuja la triangulacion en 2D
  //Notese que hay que cambiar algunas cosas del setup si se desea sacar en 2D y no en 3D.
  public void dibujar2D()
  {    
    stroke(0);
    strokeWeight(1);
    int nelms = 0;
    for (int i = 0; i < aristas.length; i++)
    {
      if (aristas[i] == null) {
      }
      else { 
        nelms++;
      }
    }
    int i = 0;
    while (i<nelms)
    {
      line((float) aristas[i].origen.x, (float) aristas[i].origen.y, 0, (float) aristas[i].siguiente.origen.x, (float) aristas[i].siguiente.origen.y, 0);
      i++;
    }
  }

  //Metodo que dibula la triangulacion en 3D
  public void dibujar3D()
  {
    stroke(0);
    strokeWeight(1);
    int nelms = 0;
    for (int i = 0; i < aristas.length; i++)
    {
      if (aristas[i] == null) {
      }
      else { 
        nelms++;
      }
    }
    int i = 0;
    while (i<nelms)
    {
      line((float) aristas[i].origen.x, (float) aristas[i].origen.y, (float) aristas[i].origen.z, (float) aristas[i].siguiente.origen.x, (float) aristas[i].siguiente.origen.y, (float) aristas[i].siguiente.origen.z);
      i++;
    }
  }


  //Metodo que dadas unas coordenadas X,Y, calcula la cara a la que pertenece, lo mete en el plano y crea un punto con coordenadas X,Y,Z
  public Punto crearPunto(double x, double y, Cara[] c)
  {
    int nelms = 0;
    for (int i = 0; i < c.length; i++)
    {
      if (c[i] == null) {
      }
      else { 
        nelms++;
      }
    }

    Cara caraquelocontiene = null;
    boolean found = false;

    //empieza el bucle en 1 por que el punto sabemos que no estara en la cara de fuera.
    for (int i = 1; i < nelms && !found; i++)
    {
      if (pertenece(x, y, c[i]))
      {
        caraquelocontiene = c[i];
        found = true;
      }
    }

    double altura = coordZ(x, y, caraquelocontiene);
    Punto punto = new Punto(x, y, altura);
    return punto;
  }

  //metodo que calcula la coordenada de un punto dado por las coordenadas X,Y, sabiendo que pertenece a la cara C
  public double coordZ(double x, double y, Cara cara)
  {
    double x1 = cara.arista.origen.x;
    double y1 = cara.arista.origen.y;
    double z1 = cara.arista.origen.z;

    double x2 = cara.arista.anterior.origen.x;
    double y2 = cara.arista.anterior.origen.y;
    double z2 = cara.arista.anterior.origen.z;

    double x3 = cara.arista.siguiente.origen.x;
    double y3 = cara.arista.siguiente.origen.y;
    double z3 = cara.arista.siguiente.origen.z;

    double A = (y-y1)*(x2-x1)*(z3-z1) + (z2-z1)*(y3-y1)*(x-x1) - (x-x1)*(y2-y1)*(z3-z1) - (y-y1)*(z2-z1)*(x3-x1);
    double B = (x2-x1)*(y3-y1) - (y2-y1)*(x3-x1);

    return (A/B + z1);
  }

  //metodo que dice si un punto pertenece a una cara
  public boolean pertenece(double cx, double cy, Cara cara)
  {
    double ax = cara.arista.origen.x;
    double ay = cara.arista.origen.y;

    double bx = cara.arista.anterior.origen.x;
    double by = cara.arista.anterior.origen.y;

    double dx = cara.arista.siguiente.origen.x;
    double dy = cara.arista.siguiente.origen.y;

    return ((ax-cx)*(by-cy) - (ay-cy)*(bx-cx) >= 0 && (bx-cx)*(dy-cy) - (by-cy)*(dx-cx) >= 0 && (dx-cx)*(ay-cy) - (dy-cy)*(ax-cx) >= 0);
  }


  //Metodo que dice si el punto D esta (en coords 2D) en el circulo que contiene a A,B,C o no. Si esta en la frontera, se considera que esta dentro
  public boolean incircle(Punto a, Punto b, Punto c, Punto d)
  {
    double ax = a.x;
    double ay = a.y;
    double bx = b.x;
    double by = b.y;
    double cx = c.x;
    double cy = c.y;
    double dx = d.x;
    double dy = d.y;

    return (
    (ax-dx)*(by-dy)*((cx-dx)*(cx-dx)+(cy-dy)*(cy-dy)) + (bx-dx)*(cy-dy)*((ax-dx)*(ax-dx)+(ay-dy)*(ay-dy)) +
      (cx-dx)*(ay-dy)*((bx-dx)*(bx-dx)+(by-dy)*(by-dy)) 
      - ((cx-dx)*(cx-dx)+(cy-dy)*(cy-dy))*(ay-dy)*(bx-dx) -
      ((ax-dx)*(ax-dx)+(ay-dy)*(ay-dy))*(by-dy)*(cx-dx) - ((bx-dx)*(bx-dx)+(by-dy)*(by-dy))*(cy-dy)*(ax-dx) >= 0
      );
  }

  //Metodo que flipa las aristas necesarias hasta llegar a una triangulacion de DELONE.
  public void flip(Arista aristas[], Cara caras[])
  {
    int nelms = 0;
    for (int i = 0; i < aristas.length; i++)
    {
      if (aristas[i] == null) {
      }
      else { 
        nelms++;
      }
    }

    //si ha habido algun flip, hay que repetir la operacion en todas las aristas
    boolean flip = true;

    while (flip)
    {
      flip = false;
      for (int i = 0; i < nelms; i++)
      {
        if (arinterior(aristas[i]) && arinterior(aristas[i].gemela))
        {
          if (!incircle(aristas[i].origen, aristas[i].siguiente.origen, aristas[i].anterior.origen, aristas[i].gemela.anterior.origen))
          {
            Arista aux1 = aristas[i].gemela.siguiente;
            Arista aux2 = aristas[i].siguiente;

            aristas[i].gemela.anterior.siguiente = aristas[i].siguiente;
            aristas[i].gemela.anterior.anterior = aristas[i].gemela;
            aristas[i].siguiente.anterior = aristas[i].gemela.anterior;
            aristas[i].siguiente.siguiente = aristas[i].gemela;

            aristas[i].gemela.siguiente.siguiente = aristas[i];
            aristas[i].gemela.siguiente.anterior = aristas[i].anterior;
            aristas[i].anterior.anterior = aristas[i];
            aristas[i].anterior.siguiente = aristas[i].gemela.siguiente;

            aristas[i].gemela.origen = aristas[i].anterior.origen;
            aristas[i].gemela.anterior = aristas[i].siguiente;
            aristas[i].gemela.siguiente = aristas[i].gemela.anterior.anterior;

            aristas[i].origen = aristas[i].gemela.siguiente.origen;
            aristas[i].anterior = aristas[i].anterior.siguiente;
            aristas[i].siguiente = aristas[i].anterior.anterior;

            aristas[i].gemela.anterior.cara = aristas[i].cara;
            aristas[i].anterior.cara = aristas[i].gemela.cara;
            //He cambiado aqui el gemela, y quitar comentarios 2 ultimos de los 4 siguientes

            //caras[aristas[i].cara.numCara].arista = aristas[i];
            //caras[aristas[i].gemela.cara.numCara].arista = aristas[i].gemela;
            aux1.cara = aristas[i].cara;
            aux2.cara = aristas[i].gemela.cara;

            aristas[i].cara.arista = aristas[i];
            aristas[i].gemela.cara.arista = aristas[i].gemela;

            flip = true;
          }
        }
      }
    }
  }

  //Metodo que devuelve true si una arista es interior
  public boolean arinterior(Arista ax)
  {
    return (ax.cara.numCara != 0);
  }


  //metodo que devuelve un array de boolean cuyas posiciones en true representan que el punto de esa posicion puede ser borrado
  public boolean[][] nBorrar(double[][] p, double err)
  {
    double err2 = 0-err;

    boolean[][] borrados = new boolean[p.length][p[0].length];

    for (int i = 1; i < p.length - 1; i++)
    {
      for (int j = 1; j < p[i].length - 1; j++)
      {
        double d1 = p[i][j] - p[i-1][j-1];
        double d2 = p[i+1][j+1] - p[i][j];
        double d3 = p[i][j] - p[i-1][j];
        double d4 = p[i+1][j] - p[i][j];
        double d5 = p[i][j] - p[i-1][j+1];
        double d6 = p[i+1][j-1] - p[i][j];
        double d7 = p[i][j] - p[i][j+1];
        double d8 = p[i][j-1] - p[i][j];

        double v1 = d1-d2;
        double v2 = d3-d4;
        double v3 = d5-d6;
        double v4 = d7-d8;

        if ( (v1 > err2 && v1 < err) && (v2 > err2 && v2 < err) && (v3 > err2 && v3 < err) && (v4 > err2 && v4 < err) )
          borrados[i][j] = true;
      }
    }

    return borrados;
  }

  //metodo que toma como argumentos una matriz de int y otra de booleanos, y convierte las posiciones que tengan true en la de booleanos con -1 en la de ints ("borrado")
  public void update(double[][] p, boolean[][] c)
  {
    for (int i = 0; i < c.length; i++)
      for (int j = 0; j < c[i].length; j++)
        if (c[i][j] == true)
          p[i][j] = -1;
  }

  //metodo que dado un array de puntos, te encuentra la posicion del siguiente punto no null respecto de la posicion pasada
  public int nextP(Punto[] p, int current)
  {
    //si el pasado es el ultimo del array, devuelve -2 (para saber si hemos llegado ya al final)
    if (current == p.length)
      return -2;

    int res = 0;
    boolean found = false;
    for (int i = current+1; i < p.length && !found; i++)
    {
      if (p[i] == null)
      {
      }
      else
      {
        res = i;
        found = true;
      }
    }
    return res;
  }

  //main, donde creamos todo
  public void calcular()
  {
    /*double [][] heights = {
      {200,180,160,140,120,100},
      {160,140,120,250,125,150},
      {145,125,105,85,140,140},
      {160,180,180,65,80,90}
    };*/
        
    //inicializamos un array con las alturas
    double [][] heights = {
 {783.832, 837.717, 830.222, 803.088, 813.977, 787.54, 761.635, 786.034, 792.921, 749.43, 793.41, 807.931, 824.049, 819.34, 814.379, 809.16, 825.01, 836.92, 841.3, 843.48, 845.24, 853.86, 855.99, 874.87, 880.74, 892.62, 899.39, 902.76, 903.87, 912.37, 910.19, 911.22, 916.22, 904.041, 931.28, 932.321, 966.86, 994.967, 990.161, 987.591, 1052.191, 1079.729, 1105.11, 1078.898, 1027.348, 1072.498, 1078.18, 1059.52, 1125.01, 1073.49, 1109.89, 1103.113, 1176.73, 1248.78, 1317.329, 1458.818, 1643.133, 1816.498, 1518.223, 1598.666, 1729.432, 1628.845, 1602.542, 1631.148, 1490.59, 1474.067, 1462.483, 1353.41, 1454.805, 1498.143, 1419.43, 1385.477, 1361.797, 1376.488, 1333.49, 1333.255, 1322.38, 1163.254, 1116.671, 1119.511},
 {790.323, 816.704, 852.051, 812.342, 819.123, 793.308, 780.301, 796.537, 796.309, 802.34, 803.711, 769.76, 814.05, 822.96, 826.34, 823.65, 821.65, 836.53, 852.6, 845.22, 848.05, 853.95, 856.37, 872.54, 877.63, 895.48, 910.94, 913.947, 914.81, 923.91, 914.375, 921.14, 930.409, 926.659, 936.905, 909.277, 948.455, 1008.52, 972.25, 1021.26, 1083.302, 1089.8, 1131.889, 1106.939, 1053.59, 1087.711, 1135.22, 1063.56, 1077.68, 1081.6, 1131.67, 1173.3, 1293.7, 1458.996, 1557.944, 1824.992, 2151.556, 1826.964, 1479.346, 1468.813, 1556.469, 1760.01, 1684.306, 1608.161, 1561.534, 1416.007, 1269.98, 1217.725, 1385.704, 1556.71, 1582.046, 1515.095, 1472.473, 1488.802, 1437.22, 1367.227, 1441.471, 1394.292, 1177.334, 1190.425},
 {791.905, 810.302, 864.419, 842.952, 822.284, 799.076, 772.545, 795.35, 800.329, 803.74, 806.809, 812.859, 801.989, 821.59, 825.24, 801.22, 831.451, 840.24, 834.18, 852.44, 846.42, 847.9, 863.58, 859.35, 868.96, 882.34, 918.251, 923.931, 929.141, 929.981, 927.171, 951.181, 967.021, 963.31, 986.07, 969.841, 1008.85, 1038.275, 1028.119, 1078.543, 1085.351, 1134.599, 1097.564, 1137.795, 1145.203, 1085.759, 1123.854, 1112.721, 1092.46, 1158.518, 1214.28, 1335.4, 1668.6, 1782.3, 1844.188, 1828.313, 2006.466, 1963.688, 1714.526, 1446.853, 1255.128, 1503.402, 1786.582, 1594.374, 1562.148, 1660.576, 1631.645, 1521.665, 1221.045, 1311.89, 1717.987, 1670.082, 1714.575, 1513.084, 1624.802, 1682.135, 1538.119, 1219.706, 1284.605, 1258.136},
 {796.167, 803.122, 886.653, 868.807, 837.147, 828.162, 802.562, 816.661, 812.74, 807.47, 809.558, 812.759, 817.039, 818.489, 833.22, 861.97, 868.991, 914.459, 891.77, 857.131, 854.27, 856.5, 855.322, 853.748, 866.031, 884.501, 910.119, 936.599, 955.232, 942.271, 942.561, 960.168, 999.808, 1010.34, 1040.762, 1061.63, 1080.08, 1060.431, 1034.147, 984.966, 1020.824, 1016.71, 1067.199, 1131.771, 1166.213, 1098.253, 1113.121, 1119.65, 1227.2, 1523.6, 1584.3, 1601.2, 1730, 1954.3, 1783.576, 1827, 2017.24, 1751.361, 1605.432, 1406.357, 1515.576, 1370.651, 1584.983, 1379.729, 1643.367, 1735.866, 1446.55, 1349.177, 1243.966, 1307.521, 1283.135, 1665.163, 1412.118, 1254.021, 1598.662, 1437.583, 1421.988, 1422.826, 1209.939, 1179.406},
 {801.996, 809.569, 849.344, 880.372, 851.75, 835.502, 815.304, 809.653, 835.54, 815.241, 818.319, 816.759, 824.54, 841.759, 867.92, 883.259, 895.76, 880.01, 908.829, 894.728, 888.101, 876.17, 864.31, 862.751, 868.758, 898.36, 916.769, 946.042, 968.261, 985.721, 953.741, 977.549, 991.589, 1055.639, 1088.771, 1069.332, 1092.198, 1025.112, 1104.257, 989.079, 1087.649, 1124.503, 1170.517, 1154.277, 1139.078, 1149.514, 1142.2, 1251.6, 1593.3, 1565.8, 1489.4, 1566.6, 1985.7, 1627.6, 1491.444, 1690.037, 1891.519, 1675.577, 1441.988, 1443.505, 1309.485, 1405.305, 1343.991, 1256.672, 1553.994, 1816.311, 1663.641, 1418.91, 1318.583, 1203.174, 1293.138, 1505.093, 1279.825, 1307.549, 1305.71, 1238.959, 1242.09, 1155.816, 1115.168, 1216.333},
 {812.01, 855.231, 863.564, 891.229, 872.027, 846.446, 822.685, 815.139, 823.351, 840.47, 824.53, 822.209, 844.461, 878.951, 897.6, 901.139, 893.53, 886.231, 921.42, 937.481, 895.8, 875.98, 875.619, 870.811, 884.118, 883.169, 895.802, 956.502, 969.859, 1018.4, 997.179, 1007.439, 1025.342, 1040.471, 1096.578, 1098.249, 1112.248, 1062.102, 1082.38, 1110.912, 1078.862, 1101.027, 1178.589, 1155.622, 1150.813, 1149.236, 1242.2, 1507.9, 1781.3, 1604.5, 1388.044, 1555.999, 1807.999, 1754.3, 1500.864, 1365.9, 1776.072, 1470.607, 1448.716, 1370.138, 1483.199, 1276.32, 1230.603, 1243.871, 1286.175, 1734.258, 1442.462, 1261.098, 1158.247, 1200.103, 1306.998, 1317.714, 1218.875, 1147.612, 1223.142, 1183.452, 1161.77, 1081.258, 1046.455, 1147.747},
 {841.443, 866.267, 869.232, 902.597, 880.431, 852.573, 834.648, 822.555, 824.78, 837.591, 837.521, 829.219, 842.85, 865.26, 883.25, 892.602, 878.922, 868.681, 866.14, 882.721, 894.758, 882.301, 885.079, 882.238, 887.921, 919.771, 927.579, 891.558, 991.389, 1026.41, 1047.29, 1084.38, 1093.542, 1098.901, 1089.859, 1157.272, 1151.978, 1087.431, 1052.742, 1097.231, 1114.341, 1174.079, 1132.14, 1178.25, 1172.41, 1238.191, 1348.9, 1716.1, 1468.8, 1398.6, 1271.95, 1584.638, 1480.339, 1626.2, 1591.96, 1341, 1380.8, 1382.274, 1256.575, 1363.374, 1214.574, 1088.764, 1408.761, 1153.442, 1198.506, 1563.968, 1747.109, 1373.711, 1288.935, 1050.752, 1201.301, 1336.322, 1189.764, 1117.849, 1105.575, 1065.098, 1052.421, 1059.477, 1105.466, 1160.039},
 {841.439, 865.56, 873.764, 883.732, 889.621, 868.877, 850.416, 827.913, 829.91, 842.14, 854.84, 835.391, 853.031, 886.51, 889.081, 887.83, 915.41, 866.281, 847.78, 895.93, 931.17, 891.09, 892.92, 893.048, 900.939, 907.239, 968.409, 994.53, 942.759, 976.69, 964.232, 995.628, 1076.81, 1106.781, 1150.429, 1183.601, 1142, 1130.772, 1091.177, 1127.192, 1180.408, 1155, 1159.702, 1209.977, 1338.78, 1528.159, 1742.8, 1554.2, 1394.1, 1207.5, 1181.538, 1215.781, 1407.933, 1399.423, 1342.7, 1407.756, 1182.536, 1263.94, 1290, 1187.8, 1525.983, 1110.439, 1239.592, 1109.956, 1169.532, 1407.856, 1631.985, 1238.814, 1313.308, 1007.305, 1138.417, 1280.978, 1201.119, 1160.676, 1142.397, 1032.745, 987.494, 965.913, 1119.319, 1072.696},
 {846.826, 866.57, 876.952, 891.331, 899.909, 876.135, 848.887, 836.076, 835.42, 838.22, 854.15, 858.22, 891.94, 911.85, 912, 922.89, 905.89, 876.24, 858.4, 877.01, 909.42, 907.57, 918.011, 922.78, 928.039, 943.918, 936.28, 993.2, 1024.13, 949.181, 1050.642, 1081.201, 1075.908, 1105.201, 1153.872, 1256.468, 1160.951, 1124.857, 1173.48, 1154.43, 1177.03, 1241.521, 1290.971, 1397.38, 1726.78, 1707.42, 1541.051, 1689.894, 1425.937, 1232.422, 1103.077, 1178.414, 1259.205, 1264.395, 1175.4, 1389.7, 1357.3, 1369.4, 1223.2, 1117, 1217.085, 1123.869, 1117.98, 1107.801, 1106.444, 1337.111, 1412.322, 1303.282, 1086.331, 1181.845, 1117.316, 1220.664, 1325.106, 1132.516, 1124.646, 1105.853, 1029.624, 1050.831, 1030.968, 1060.446},
 {848.289, 861.759, 883.29, 892.088, 906.191, 880.141, 854.578, 834.876, 842.04, 858.11, 889.42, 857.5, 929.789, 939.83, 983.52, 944.85, 894.97, 880.759, 857.56, 857.17, 951.79, 938.351, 944.43, 939.029, 943.041, 970.989, 969.391, 975.118, 1049.029, 1011.012, 1031.928, 1054.606, 1106.727, 1141.341, 1150.448, 1252.291, 1216.226, 1301.389, 1282.93, 1186.454, 1251.41, 1331.84, 1416.801, 1784.16, 1735.95, 1630.16, 1491.2, 1365.938, 1328.47, 1135.441, 1054.123, 1161.079, 1152.315, 1110.76, 1218.4, 1346, 1496.2, 1473.6, 1384, 1299.9, 1367.005, 1279.442, 984.381, 1075.6, 1049.091, 1189.152, 1235.563, 1269.211, 1105.433, 1034.482, 1175.287, 1305.981, 1195.837, 1143.556, 1062.755, 1015.775, 1013.198, 960.476, 1045.96, 1009.378},
 {848.351, 865.726, 877.75, 891.781, 914.473, 883.856, 854.407, 854.819, 864.75, 872.14, 921.36, 923, 949.68, 930.76, 930.92, 885.149, 857.43, 893.3, 876.31, 850.95, 902.51, 959.62, 950.861, 957.089, 974.818, 993.799, 1028.312, 968.6, 1081.301, 1058.929, 1083.22, 1069.61, 1082.941, 1117.183, 1175.518, 1228.821, 1451.084, 1689.616, 1433.859, 1295.711, 1316.84, 1425.78, 1562.3, 1882.27, 1378.331, 1471.049, 1305, 1186.182, 1157.251, 1119.164, 1039.084, 1061.105, 1085.117, 1126.708, 1240.8, 1477.58, 1606.8, 1582.724, 1482.4, 1266.1, 1301.628, 1263.803, 1064.045, 966.27, 951.748, 1120.543, 1311.064, 1112.991, 1098.654, 1055.837, 1156.125, 1399.894, 1280.644, 1241.862, 1031.569, 943.123, 980.13, 981.947, 963.384, 1028.871},
 {848.888, 870.976, 886.834, 885.871, 920.699, 881.374, 850.635, 869.899, 880.99, 916.28, 916.271, 897.85, 894.71, 900.2, 897.04, 878.01, 875.65, 909.41, 900.9, 869.66, 922.539, 915.11, 901.49, 944.852, 961.978, 999.301, 1041.139, 1030.678, 1057.731, 1102.83, 1106.069, 1113.146, 1130.281, 1164.542, 1214.672, 1320.124, 1761.98, 1896.111, 1625.16, 1427.47, 1356.45, 1730.6, 2072.6, 1791.54, 1527.445, 1156.62, 1131.967, 1141.45, 1043.922, 1126.274, 1024.779, 987.366, 1081.458, 1130.715, 1360.6, 1670.6, 1245.784, 1257.48, 1692.8, 1266.3, 1114.654, 1095.82, 1135.102, 1045.734, 1018.944, 1036.039, 1063.386, 1064.007, 1070.429, 1160.681, 1221.723, 1251.221, 1156.426, 1210.609, 957.399, 936.825, 965.711, 936.448, 990.997, 972.936},
 {851.788, 874.096, 898.196, 891.817, 881.023, 873.343, 873.164, 905.642, 912.1, 901.99, 915.44, 904.08, 917.31, 899.99, 901.08, 884.581, 883.31, 905.23, 907.961, 893.26, 870.73, 898.46, 936.713, 951.141, 973.426, 1045.894, 1041.901, 1082.478, 1078.306, 1098.667, 1119.448, 1196.624, 1159.113, 1220.898, 1324.981, 1688.602, 1896.672, 1852.419, 1847.19, 1722.82, 1500.18, 1918.31, 1977.6, 1743.8, 1248.74, 1136.02, 1063.615, 1011.977, 979.703, 1010.76, 988.825, 1071.883, 1012.695, 1111.732, 1472.8, 1567.5, 1342.8, 1171.6, 1426.4, 1766.1, 1320, 1325.335, 1141.074, 1057.516, 908.756, 997.775, 1031.465, 1089.035, 1069.415, 1030.133, 1150.205, 1251.907, 1131.662, 999.011, 1000.911, 970.379, 991.879, 983.784, 985.654, 976.139},
 {857.764, 878.262, 908.165, 912.681, 929.644, 877.123, 864.701, 957.52, 925.9, 925.92, 917.42, 923.46, 917.33, 914.24, 904.18, 899.65, 884.65, 896.77, 911.64, 912.19, 896.15, 871.149, 956.774, 974.841, 987.735, 1041.817, 1070.964, 1052.278, 1070.112, 1110, 1142.798, 1177.125, 1223.345, 1286.069, 1437.574, 1949.362, 1979.21, 2071.692, 2055.047, 1994.971, 1854.227, 1901.734, 1631.219, 1378.791, 1183.486, 1104.158, 1052.449, 997.353, 940.367, 954.019, 983.899, 941.906, 1053.391, 1065.188, 1296.872, 1279.471, 1288.989, 1081.887, 1427.914, 1669.84, 1592.599, 1273.62, 1424.255, 1044.554, 895.085, 1044.576, 1038.086, 1012.843, 895.742, 1000.258, 949.831, 1053.02, 1024.4, 996.41, 957.017, 1009.466, 913.32, 862.61, 908.747, 934.292},
 {862.534, 879.979, 914.211, 926.543, 918.665, 886.76, 871.826, 990.5, 934.74, 922.13, 934.21, 950.91, 943.08, 937.63, 912.35, 910.13, 893.47, 894.78, 916.54, 920.72, 913.22, 892.45, 929.621, 981.323, 988.472, 1024.75, 1056.117, 1054.099, 1065.45, 1102.788, 1147.296, 1231.563, 1479.018, 1521.341, 1508.731, 1611.516, 2007.87, 2136.394, 1944.966, 1707.641, 1475.871, 1373.033, 1325.71, 1388.92, 1269.142, 1085.312, 1005, 1005, 1016.968, 1053.948, 1041.538, 960.999, 1001.103, 1062.961, 1290.169, 1094.511, 1031.045, 1141.14, 1425.412, 1222.622, 1333.466, 1073.403, 981.649, 973.359, 865.064, 922.771, 1030.247, 1050.863, 976.413, 981.302, 1000.122, 1068.021, 991.359, 948.698, 918.304, 970.405, 988.576, 951.719, 831.699, 920.093},
 {876.512, 892.823, 896.884, 905.969, 910.776, 898.38, 877.635, 970.09, 960.85, 951.29, 945.18, 953.52, 944.24, 966.77, 933.14, 914.56, 884.57, 905.97, 912.08, 927.88, 930.3, 913.23, 902.207, 894.282, 926.499, 924.777, 965.831, 1056.788, 1075.437, 1113.51, 1184.155, 1309.089, 1546.781, 1710.631, 1812.816, 1849.062, 1777.838, 1666.898, 1597.25, 1557.641, 1222.405, 1124.411, 1292.44, 1341.243, 1128.126, 1047.432, 1033.158, 1104.864, 1169.279, 1093.332, 1041.204, 969.312, 937.215, 1020.068, 1129.649, 1007.91, 1262.664, 1245.96, 1287.71, 1097.848, 1044.735, 1028.333, 861.673, 910.082, 984.035, 1065.127, 1031.647, 1024.584, 849.393, 1005.752, 1076.642, 1011.763, 901.557, 871.8, 856.919, 936.564, 906.906, 935.152, 900.613, 819.004},
 {869.831, 888.445, 900.645, 915.913, 936.572, 913.111, 902.996, 971.79, 965.26, 973.34, 965.52, 951.09, 940.48, 955.63, 939.71, 919.49, 884.44, 919.24, 926.841, 938.761, 953.94, 922.95, 905.188, 934.913, 973.253, 1028.153, 1050.646, 1015.031, 1081.497, 1119.901, 1307.997, 1588.025, 1438.259, 1543.665, 1783.941, 1941.426, 1580.748, 1429.694, 1317.696, 1247.138, 1087, 1087.017, 1093.501, 1058.512, 1035.539, 1059.421, 1106.499, 1119.507, 1121.063, 1031.133, 970.252, 965.257, 928.589, 990.485, 1057.846, 1006.371, 972.005, 1034.515, 1059.866, 981.015, 1028.252, 915.713, 961.307, 887.783, 970.386, 1009.258, 983.306, 1008.09, 870.819, 925.58, 995.51, 976.442, 945.943, 898.113, 824.703, 896.294, 945.44, 854.458, 872.525, 800.491},
 {872.567, 880.537, 905.45, 912.719, 941.042, 914.465, 935.565, 1001.83, 989.89, 998.96, 977.56, 976.11, 936.329, 921.16, 926.7, 925.99, 912.57, 938.95, 952.7, 957.66, 985.56, 945.8, 914.399, 931.967, 994.423, 1002.511, 1070.702, 1067.102, 1054.851, 1108.957, 1190.927, 1193.619, 1424.063, 1900.64, 1949.89, 1758.58, 1442.52, 1191.51, 1132.145, 1102.296, 1104.333, 1382.03, 1427.654, 1092.374, 1216.005, 1110.645, 1239.204, 1230.772, 1054.284, 1001.791, 979.204, 953.803, 897.125, 963.64, 991, 904.7, 941.802, 985.818, 891.544, 927.201, 921.157, 955.022, 932.168, 809.162, 916.942, 1007.187, 935.522, 980.879, 888.873, 824.496, 859.896, 863.971, 844.038, 834.149, 848.629, 857.763, 888.139, 835.652, 879.811, 786.627},
 {875.392, 890.374, 908.83, 914.038, 920.667, 903.823, 1030.27, 1026.3, 1014.15, 1002.93, 978.43, 969.42, 960.34, 946.08, 943.67, 934.37, 911.8, 967.65, 983.971, 1006.29, 996.66, 964.631, 922.109, 936.591, 1049.82, 1053.14, 1076.512, 1108.292, 1114.073, 1131.276, 1129.96, 1183.734, 1416.304, 1846.28, 1930.71, 1435.01, 1219.89, 1130.64, 1107.945, 1123.025, 1299.719, 1495.26, 1265.029, 1121.222, 1340.279, 1187.763, 1311.389, 1112.016, 1001.023, 964.435, 955.691, 938.296, 874.793, 927.469, 882.8, 846.6, 973.044, 840.949, 860.832, 868.097, 913.317, 793.738, 780.909, 887.74, 889.617, 982.648, 972.945, 938.87, 903.997, 792.59, 915.651, 861.391, 856.534, 777.465, 767.323, 785.243, 788.773, 793.048, 788.46, 779.246},
 {893.001, 906.925, 915.8, 921.411, 930.741, 917.566, 963.109, 1041.76, 1028.66, 1024.46, 984.9, 963.7, 977.23, 984.5, 971.4, 943.84, 902.43, 935.77, 975.79, 1055.85, 1005.851, 962.96, 940.78, 963.903, 992.384, 1088.914, 1084.62, 1139.017, 1187.526, 1239.529, 1160.506, 1251.28, 1583.095, 2087.3, 1849.53, 1388.52, 1161.68, 1148.22, 1146.854, 1278.448, 1635.853, 1357.12, 1205.422, 1519.534, 1374.761, 1504.491, 1702.212, 1207.148, 1030.649, 1031.701, 998.092, 953.163, 846.599, 902.201, 1108.876, 1199.79, 952.009, 790.054, 934.859, 924.458, 886.382, 759.615, 782.354, 839.184, 908.649, 936.592, 962.247, 944.327, 916.655, 763.746, 905.501, 834.97, 767.104, 741.28, 819.593, 787.354, 794.528, 848.227, 799.636, 771.707},
 {922.085, 910.725, 929.543, 936.966, 943.123, 929.979, 996.492, 996.71, 1020.29, 1019.18, 998.51, 965.18, 986.3, 1003.87, 972.19, 936.76, 909.55, 951.85, 997.51, 1037.371, 1006.27, 983.589, 956.408, 979.422, 1049.077, 1059.886, 1145.187, 1262.011, 1268.363, 1248.64, 1206.175, 1337.224, 1642.55, 1977.36, 1716.47, 1325.47, 1179.92, 1225.4, 1436.534, 1498.107, 1480.511, 1485.586, 1401.549, 1757.408, 1604.885, 1712.11, 1371.755, 1277.945, 1410.451, 1241.457, 1062.356, 974.607, 928.936, 1007.991, 1030.44, 967.585, 866.685, 704.46, 863.912, 846.432, 763.765, 823.528, 885.764, 849.177, 942.142, 943.549, 942.231, 921.309, 909.764, 758.627, 899.143, 853.859, 740.087, 797.567, 782.434, 888.718, 888.777, 915.013, 865.742, 881.68},
 {941.518, 938.107, 943.026, 955.172, 923.242, 954.85, 1055.55, 1054.27, 1022.2, 1053.83, 992.99, 997.54, 1002.35, 1032.77, 1007.22, 959.87, 928.339, 998.74, 1028.55, 1031.99, 1034.829, 988.361, 1029.355, 1050.121, 1104.636, 1143.765, 1193.522, 1258.545, 1449.849, 1294.021, 1258.924, 1483.903, 1736.023, 2170.91, 1853.93, 1290.67, 1258.67, 1346.32, 1640.294, 1721.496, 1658.595, 1717.057, 1332.496, 1259.895, 1336.551, 1199.885, 1110.386, 1044.018, 1079.461, 1027.79, 984.636, 962.84, 924.298, 949.512, 917.905, 781.635, 698.55, 708.472, 716.605, 722.471, 776.099, 784.306, 836.168, 883.968, 869.6, 953.031, 948.012, 902.115, 853.58, 782.15, 835.588, 793.651, 732.808, 828.695, 837.498, 866.021, 879.849, 909.03, 1010.679, 1024.762},
 {961.219, 941.421, 946.581, 967.951, 960.457, 964.968, 1016.502, 1054.369, 1037.918, 1061.19, 1003.201, 993.284, 1048.533, 1052.005, 962.204, 979.56, 954.5, 999.301, 1013.98, 1037.601, 1052.49, 1077.53, 1083.049, 1123.845, 1162.042, 1225.589, 1295.044, 1532.813, 1408.256, 1413.256, 1396.392, 1766.715, 2041.43, 2151.19, 1675.98, 1678.19, 1307.02, 1537.42, 1662.644, 1697.808, 1668.565, 1779.002, 1228.225, 1163.298, 1400.888, 1217.379, 1029.799, 999.613, 987.762, 1002.74, 956.349, 795.7, 885.849, 882.873, 741.394, 696.369, 760.636, 759.518, 787.851, 844.727, 845.132, 926.941, 929.927, 946.957, 934.69, 878.091, 919.706, 851.941, 848.883, 794.727, 746.745, 753.423, 696.566, 782.897, 813.009, 805.583, 867.346, 858.725, 932.968, 869.248},
 {965.889, 921.499, 959.537, 995.065, 981.938, 970.89, 1073.818, 1081.484, 1075.894, 1079.115, 1025.803, 1023.969, 1053.338, 1035.399, 963.314, 1029.494, 1013.731, 936.77, 973.26, 985.239, 1074.573, 1101.539, 1111.045, 1168.196, 1244.502, 1347.902, 1579.785, 1773.228, 1562.028, 1489.278, 1415.206, 1590.69, 1810.69, 1855.66, 1535.26, 1497.23, 1539, 1683.91, 1630.968, 1641.572, 1405.387, 1461.933, 1162.709, 1307.038, 1167.697, 1167.131, 994.173, 911.101, 940.329, 922.241, 862.631, 794.504, 768.076, 736.347, 722.691, 685.169, 784.5, 857.785, 880.033, 901.012, 910.277, 921.025, 916.929, 925.179, 923.975, 847.058, 875.444, 835.569, 812.802, 791.649, 752.003, 735.339, 694.378, 761.59, 793.975, 800.904, 815.035, 887.553, 817.779, 898.666},
 {921.089, 937.033, 982.859, 1006.591, 1000.241, 958.583, 1084.814, 1050.228, 1101.254, 1094.188, 1052.974, 1040.342, 1081.658, 1024.164, 1000.813, 1009.166, 996.825, 986.997, 1018.045, 1033.564, 1083.793, 1171.302, 1384.2, 1512.183, 1377.74, 1620.699, 2003.41, 1883.59, 1820.36, 1418.79, 1571.03, 1531.48, 1935.3, 1862.03, 1902.412, 1895.983, 2025.992, 2042.7, 1908.929, 1990.598, 1474.321, 1181.501, 1099.644, 1032.582, 991.95, 935.121, 916.29, 897.301, 880.111, 888.121, 783.024, 748.696, 700.694, 702.591, 695.9, 670.9, 763.8, 815.9, 885.113, 893.084, 907.197, 911.059, 874.833, 895.725, 913.278, 824.611, 840.408, 868.616, 793.632, 792.346, 773.403, 758.156, 702.078, 735.172, 739.544, 780.004, 760.516, 785.421, 785.475, 843.243},
 {917.738, 973.187, 1014.027, 1039.875, 1012.039, 962.7, 1085.106, 1113.979, 1093.734, 1097.678, 1089.524, 1059.844, 1058.573, 1027.893, 1131.555, 1059.974, 1110.615, 1033.996, 1057.976, 1012.489, 1135.616, 1350.91, 1538.956, 1865.399, 1942.745, 1900.216, 1732.68, 1789.66, 1756.43, 1756.39, 1709.1, 1829.63, 2013.91, 2152.88, 2198.865, 2008.906, 1853.673, 1772.12, 1452.137, 1359.197, 1271.219, 1091.7, 985.486, 921.831, 869.445, 858.724, 876.772, 898.924, 872.197, 870.537, 927.934, 879.264, 746.98, 703.515, 663.8, 734.3, 757.8, 873.2, 866.799, 883.996, 898.173, 901.524, 860.747, 907.913, 910.575, 835.607, 806.754, 856.63, 817.881, 778.988, 768.089, 710.291, 698.893, 714.121, 717.782, 754.001, 763.972, 787.195, 817.859, 1000.541},
 {976.443, 991.487, 1038.972, 1083.59, 1078.809, 1020.958, 1088.958, 1071.744, 1081.228, 1097.453, 1094.904, 1126.75, 1142.734, 1119.4, 1166.491, 1135.316, 1124.583, 1321.314, 1280.049, 1073.514, 1149.529, 1275.749, 1395.452, 1487.273, 1556.991, 1530.629, 1593.27, 1802.5, 1607.84, 1690.17, 1790.96, 1899.18, 2127.55, 1905.33, 1688.397, 1493.085, 1622.608, 1718.41, 1400.793, 1111.667, 1060.52, 1021.248, 962.066, 950.533, 914.637, 840.392, 830.443, 832.26, 840.926, 890.925, 927.123, 880.955, 735.922, 702.218, 667.5, 724.9, 775.9, 858.4, 853.187, 869.137, 891.557, 894.333, 826.557, 901.202, 895.135, 818.181, 781.94, 858.121, 790.815, 751.228, 712.529, 691.832, 701.524, 738.551, 751.342, 764.641, 849.636, 820.903, 994.178, 996.152},
 {1054.995, 1076.833, 1092.887, 1134.208, 1120.615, 1067.968, 1056.746, 1099.156, 1130.792, 1169.135, 1127.063, 1143.902, 1185.315, 1179.861, 1133.286, 1163.239, 1156.231, 1224.468, 1541.768, 1138.038, 1160.919, 1209.855, 1253.253, 1467.501, 1366.37, 1460.92, 1753.83, 1509.44, 1582.79, 1414.99, 1486.92, 1497.89, 1847.99, 1857.11, 1326.31, 1220.265, 1212.955, 1633.71, 1323.894, 1010.341, 963.513, 936.652, 980.084, 980.013, 904.427, 885.959, 902.123, 890.172, 840.302, 854.155, 873.591, 875.574, 749.139, 678.711, 660.8, 712.7, 782, 835.2, 801.5, 873.2, 880.567, 884.659, 807.924, 871.494, 888.239, 891.61, 770.934, 818.984, 776.181, 722.469, 698.218, 684.473, 695.877, 738.834, 800.034, 796.662, 865.775, 986.841, 992.911, 1001.138},
 {1124.486, 1153.626, 1151.183, 1124.08, 1083.722, 1042.115, 1105.696, 1166.736, 1191.999, 1220.062, 1179.183, 1173.599, 1240.92, 1277.698, 1204.976, 1212.535, 1286.457, 1304.44, 1245.326, 1151.623, 1134.836, 1158.717, 1193.75, 1320.193, 1347.72, 1567.07, 1681.18, 1372.75, 1266.8, 1241.79, 1539.68, 1321, 1462.462, 1256.92, 1443.177, 1211.282, 1186.609, 1262.903, 947.985, 909.241, 914.649, 910.585, 946.669, 896.869, 950.198, 1038.077, 964.803, 965.216, 880.088, 845.071, 874.654, 762.203, 726.296, 644.996, 672, 695.5, 778.9, 789.2, 829.2, 863.1, 850.487, 818.315, 787.226, 874.048, 835.882, 855.796, 760.85, 792.087, 763.563, 704.538, 685.469, 665.381, 722.667, 774.41, 832.236, 908.502, 982.571, 980.019, 987.901, 996.693},
 {1111.996, 1156.288, 1151.096, 1085.744, 1096.283, 1100.22, 1155.877, 1239.067, 1490.39, 1372.973, 1298.142, 1265.13, 1289.301, 1314.824, 1287.237, 1260.119, 1304.343, 1201.131, 1149.626, 1175.803, 1175.151, 1319.242, 1245.211, 1406.18, 1335.7, 1614.51, 1237.92, 1174.49, 1105.05, 1212.71, 1195.51, 1198.52, 1103.516, 1078.312, 991.113, 1014.815, 1035.413, 930.828, 888.998, 888.998, 893.389, 909.719, 967.232, 1061.38, 1192.614, 1130.139, 1072.581, 907.623, 882.609, 786.271, 862.637, 732.251, 691.771, 630.43, 670.4, 691.9, 754.6, 765.2, 847.1, 817.8, 863.496, 828.202, 771.279, 800.207, 822.758, 795.271, 777.157, 715.736, 746.499, 699.681, 674.961, 728.833, 768.534, 808.911, 917.443, 978.029, 971.719, 981.952, 982.043, 991.663},
 {1142.909, 1145.392, 1117.146, 1079.157, 1126.579, 1143.86, 1178.108, 1350.161, 1395.986, 1642.226, 1426.628, 1398.294, 1375.238, 1338.68, 1325.966, 1294.576, 1257.364, 1331.112, 1374.442, 1231.696, 1263.425, 1295.935, 1243.49, 1307.78, 1471.3, 1271.74, 1070.09, 1045.75, 1110.46, 1223.28, 1164.789, 1086.966, 1028.128, 981.98, 966.007, 916.752, 906.2, 915.579, 944.012, 888.998, 910.63, 928.759, 1033.863, 960.983, 1082.369, 980.081, 977.127, 878.499, 847.552, 813.543, 765.884, 714.938, 678.177, 630.987, 656.4, 684.8, 747.4, 770.8, 841.7, 818.7, 808.892, 788.069, 761.696, 787.397, 871.629, 849.814, 820.388, 803.816, 695.547, 686.88, 656.951, 702.551, 749.074, 829.374, 972.002, 921.842, 968.1, 922.071, 981.073, 981.311},
 {1138.812, 1179.177, 1138.145, 1107.6, 1151.583, 1149.006, 1146.919, 1193.954, 1251.607, 1308.068, 1283.442, 1270.728, 1268.684, 1273.558, 1289.152, 1314.236, 1414.524, 1658.759, 1438.422, 1549.982, 1506.308, 1556.541, 1569.16, 1590.63, 1641.02, 1146.62, 1029.52, 995.53, 1007.5, 1089.79, 1047.183, 1135.988, 1022.558, 973.236, 939.019, 956.328, 1004.781, 975.932, 913.589, 878.556, 922.647, 948.942, 987.9, 933.108, 1005.242, 933.608, 886.122, 832.18, 837.124, 651.193, 685.84, 738.256, 632.685, 635.012, 659.2, 681.1, 755.9, 790.5, 834.4, 800.3, 790.1, 756.7, 736.151, 788.349, 856.379, 841.569, 809.641, 766.874, 714.286, 678.16, 650.616, 688.825, 755.255, 814.913, 806.706, 965.898, 912.554, 980.461, 982.303, 837.456},
 {1167.546, 1177.147, 1131.317, 1134.291, 1160.447, 1156.703, 1166.584, 1319.206, 1248.796, 1245.5, 1251.049, 1251.19, 1285.043, 1300.125, 1307.706, 1375.084, 1467.35, 1651.1, 1525.24, 1607.92, 1653.73, 1621.04, 1672.732, 1595.82, 1287.22, 1167.36, 984.97, 963.08, 954.78, 949.96, 1009.027, 1281.362, 978.449, 978.349, 1020.432, 933.45, 914.432, 891.736, 876.609, 841.096, 880.386, 931.974, 919.373, 881.836, 925.396, 816.875, 832.217, 755.497, 678.342, 640.105, 686.799, 717.354, 619.432, 631.298, 653, 674.3, 735.8, 782.9, 827.9, 803.8, 756.3, 731.8, 728.056, 788.26, 838.46, 813.787, 793.291, 735.988, 690.348, 673.247, 643.953, 708.434, 774.774, 963.311, 954.441, 964.398, 950.531, 966.061, 971.883, 958.359},
 {1202.281, 1195.135, 1187.371, 1132.355, 1178.254, 1203.987, 1237.824, 1242.88, 1290.255, 1263.89, 1293.734, 1363.851, 1360.705, 1373.236, 1473.395, 1501.95, 1600.72, 1555.3, 1470.48, 1593.02, 1559.72, 1510.66, 1459.975, 1455.02, 1251.79, 1153.03, 1001.474, 937.87, 925.488, 950.743, 924.642, 937.364, 941.15, 1192.077, 1049.493, 992.659, 1017.582, 1037.116, 944.916, 871.489, 872.786, 905.849, 859.082, 844.67, 850.934, 809.276, 737.205, 681.496, 686.397, 647.891, 654.821, 697.4, 613.092, 636.394, 650.9, 674, 722.3, 752.3, 788.9, 753.1, 738.8, 712.311, 751.941, 820.464, 812.809, 815.066, 762.664, 709.242, 677.988, 652.949, 679.182, 719.666, 774.863, 772.017, 951.309, 925.488, 954.131, 956.596, 897.769, 969.545},
 {1082.61, 1109.678, 1144.962, 1173.406, 1206.723, 1260.457, 1353.117, 1397.566, 1367.496, 1384.592, 1299.166, 1332.597, 1422.359, 1538.009, 1605.79, 1503.26, 1476.83, 1476.19, 1388.57, 1513.72, 1514.59, 1408.64, 1437.5, 1428.54, 1242.44, 1113.22, 978.16, 918.33, 902.657, 883.061, 881.044, 902.116, 986.738, 1281.298, 1210.022, 1130.333, 1122.866, 1065.174, 952.972, 894.611, 814.84, 849.615, 817.157, 806.985, 743.166, 704.182, 726.096, 683.003, 665.701, 640.303, 626.999, 677.897, 616.898, 635.802, 649.32, 673.728, 725.595, 751, 794.4, 743.1, 709.1, 743.9, 741, 784.4, 809.2, 789.9, 720.989, 709.547, 666.707, 648.038, 664.489, 710.937, 751.183, 892.74, 953.04, 812.256, 951.327, 962.082, 793.735, 965.315},
 {1086.733, 1156.183, 1182.012, 1256.575, 1242.039, 1344.008, 1401.595, 1459.361, 1508.812, 1471.749, 1466.434, 1431.037, 1549.548, 1536.731, 1624.582, 1514.57, 1494, 1290.04, 1287.75, 1470.27, 1355.43, 1437.48, 1503.85, 1544.35, 1349.11, 1159.12, 919.74, 901.76, 890.04, 880.94, 869.849, 928.249, 996.478, 1043.825, 1178.521, 1089.278, 1024.434, 990.223, 885.467, 862.909, 766.299, 795.414, 740.085, 739.893, 740.88, 716.479, 728.604, 693.698, 691.301, 649.296, 609.698, 611.399, 610.604, 629.998, 647.307, 669.283, 685.99, 721.5, 747.3, 706.4, 697.5, 737.5, 717.5, 741.3, 795.1, 729.669, 723.228, 672.178, 657.429, 633.369, 670.333, 732.236, 794.877, 955.627, 956.41, 943.734, 938.45, 958.359, 872.73, 923.136},
 {1159.734, 1194.334, 1273.216, 1320.65, 1317.193, 1343.748, 1392.836, 1309.916, 1423.178, 1431.334, 1322.905, 1320.279, 1430.199, 1344.635, 1360.392, 1337.57, 1264.6, 1246.99, 1230.34, 1427.35, 1320.69, 1505.62, 1588.13, 1727.77, 1414.93, 986.9, 904.68, 897.78, 940.72, 895.99, 895.479, 851.108, 976.474, 913.731, 1020.062, 959.473, 951.201, 865.694, 847.027, 777.327, 725.502, 758.393, 727.355, 688.653, 718.845, 695.944, 672.096, 669.498, 682.802, 663.496, 629.003, 600.402, 612.598, 628.705, 654.617, 674.764, 710.202, 765.314, 719.286, 679.565, 774.3, 718.1, 730.6, 778.8, 746, 714.883, 678.041, 652.422, 643.556, 657.854, 717.927, 769.114, 921.589, 951.487, 924.781, 909.423, 899.246, 839.061, 944.674, 727.845},
 {1194.665, 1265.317, 1326.608, 1373.977, 1084.54, 1064.971, 1265.562, 1372.74, 1345.462, 1302.664, 1272.676, 1264.186, 1313.165, 1281.097, 1255.003, 1318.44, 1206.9, 1191, 1405.29, 1305.23, 1222.44, 1431.39, 1563.63, 1280.6, 1044.54, 910.85, 906.26, 907.53, 871.28, 908.41, 903.848, 873.733, 889.327, 890.703, 960.978, 916.189, 907.818, 755.857, 796.048, 702.45, 646.386, 746.681, 719.53, 669.055, 730.95, 704.686, 675.097, 654.704, 654.704, 675.299, 634.703, 596.998, 615.196, 639.604, 729.198, 741.69, 755.708, 740.275, 686.192, 696.517, 755.8, 677.7, 763.3, 756.8, 720, 694.001, 652.699, 633.949, 633.544, 699.485, 754.714, 920.9, 939.96, 921.069, 867.862, 825.933, 851.628, 750.258, 720.102, 897.002},
 {1313.223, 1305.631, 1304.56, 1387.47, 1092.401, 1199.338, 1340.893, 1376.934, 1293.244, 1243.823, 1220.715, 1218.6, 1256.56, 1236.683, 1119.936, 1288.12, 1235.45, 1116.92, 1289.49, 1168.34, 1339.59, 1477.29, 1301.325, 1023.006, 943.805, 878.319, 854.81, 889.806, 859.31, 879.026, 902.327, 865.77, 817.297, 865.387, 886.554, 855.902, 833.248, 715.073, 713.236, 680.727, 635.348, 688.139, 694.554, 666.477, 715.2, 719.5, 698.603, 670.203, 658.501, 614.098, 653.002, 592.698, 620.302, 669.896, 719.125, 762.879, 766.121, 712.126, 664.782, 751.595, 710.187, 704.4, 734, 704.7, 707.7, 650.994, 638.453, 618.024, 709.77, 750.199, 924.413, 929.596, 910.508, 917.367, 925.985, 905.8, 771.401, 813.788, 832.451, 948.161},
 {1290.005, 1367.931, 1390.997, 1305.536, 988.825, 1035.193, 1300.506, 1338.382, 1337.751, 1194.963, 1158.609, 1165.293, 1236.883, 1130.501, 1041.427, 1180.37, 1195.25, 1041.66, 1052.94, 1115.38, 1218.22, 1364.81, 1222.641, 1044.446, 936.684, 905.724, 872.661, 847.59, 839.084, 876.911, 896.121, 889.147, 817.417, 796.699, 789.301, 758.308, 699.214, 721.766, 667.232, 661.542, 655.349, 689.64, 657.896, 721.121, 741.484, 711.081, 707.405, 684.302, 658.199, 646.104, 618.902, 587.199, 627.301, 662.301, 695.501, 715.79, 702.302, 701.67, 641.9, 704.8, 672.3, 719.1, 696.6, 665, 660, 632.5, 621.008, 627.299, 708.683, 751.16, 780.415, 927.023, 856.911, 921.999, 914.35, 774.528, 887.644, 744.673, 755.702, 805.912},
 {1366.045, 1415.156, 1324.53, 1032.182, 945.137, 988.627, 1230.073, 1247.258, 1272.499, 1159.124, 1133.739, 1173.87, 1105.61, 1124.392, 923.25, 1040.11, 1063.73, 1172.77, 1035.42, 1098.24, 1296.46, 1208.77, 1104.584, 1370.297, 951.227, 904.704, 903.398, 831.93, 829, 848.239, 878.703, 888.44, 876.097, 789.755, 676.905, 760.495, 740.917, 697.587, 701.282, 667.252, 638.893, 652.116, 696.387, 725.583, 757.779, 734.908, 728.896, 694.897, 690.596, 645.902, 621.198, 592.003, 621.601, 665.706, 746.191, 732.471, 690.049, 674.194, 624.8, 708.7, 641.9, 667.2, 670.7, 647.3, 626.7, 614.6, 607, 670.8, 728.4, 859.306, 924.73, 851.943, 900.285, 917.405, 913.49, 830.652, 709.185, 722.729, 837.847, 949.626},
 {1420.768, 1297.562, 1040.827, 929.195, 874.429, 1018.518, 1242.257, 1188.838, 1218.763, 1099.486, 1134, 1157.093, 1006.292, 1050.05, 944.19, 975.05, 1221.37, 1236.85, 983.62, 1135.13, 1200.14, 1051.57, 990.405, 957.617, 955.549, 897.981, 900.28, 882.377, 829, 793.486, 848.438, 815.723, 736.266, 711.875, 679.092, 716.169, 724.286, 680.714, 717.496, 682.5, 652.096, 647.604, 716.096, 700.204, 714.203, 740.397, 702.903, 664.302, 645.197, 622.598, 608.6, 596.595, 592.899, 676.993, 733.789, 686.82, 654.378, 654.378, 664.4, 661.5, 653.7, 628.4, 630.3, 627.9, 608.9, 603, 647.7, 686, 854.4, 915.971, 905.382, 898.304, 891.152, 910.062, 909.805, 908.372, 708.381, 718.186, 896.965, 807.457},
 {1447.697, 1178.287, 1073.053, 949.478, 822.374, 975.772, 1220.299, 1110.012, 1104.666, 1174.755, 1086.013, 1128.484, 963.648, 870.444, 896.78, 899.87, 945.8, 1070.61, 854.22, 1013.8, 951.76, 966.35, 906.177, 932.857, 867.871, 898.132, 857.825, 864.458, 839.443, 820.978, 834.579, 733.727, 690.047, 672.036, 660.696, 698.891, 741.412, 697.536, 675.097, 666.698, 666.296, 602.295, 644.804, 705.501, 704.504, 699.801, 701, 702.5, 687.696, 648.601, 628.701, 610.1, 586.202, 697.099, 673.676, 664.383, 649.001, 651.796, 643.2, 622.3, 618.4, 614.8, 612.5, 602.5, 602, 651.6, 689.2, 900.9, 904.6, 898.301, 903.545, 881.561, 775.083, 885.075, 849.54, 878.794, 704.918, 741.554, 821.3, 934.576},
 {1397.262, 1442.52, 1263.03, 1105.009, 807.149, 1161.28, 1220.135, 1169.373, 1171.78, 995.574, 949.345, 817.221, 858.91, 780.335, 908.443, 1094.14, 973.17, 937.51, 909.82, 933.7, 1036.86, 997.87, 954.859, 872.669, 880.372, 791.12, 853.077, 798.239, 828.568, 811.13, 749.208, 671.787, 661.612, 663.397, 655.157, 673.195, 719.878, 702.025, 661.902, 636.001, 647.998, 655.501, 661.6, 673.9, 671.899, 708.4, 705.3, 680.799, 663.699, 631.099, 625.6, 584.5, 579.898, 698.102, 696.375, 653.622, 625.167, 610.195, 610.3, 610.5, 602.2, 599.8, 592.2, 593.9, 637.7, 698.1, 888.5, 875.3, 896, 896.299, 898.341, 868.639, 730.14, 864.445, 884.242, 684.364, 786.837, 900.985, 887.841, 817.519},
 {1035.727, 986.657, 963.732, 941.707, 817.231, 950.32, 1196.194, 1131.23, 1064.143, 940.991, 881.215, 857.856, 813.908, 768.844, 834.447, 848.87, 776.29, 928.8, 1054.42, 851.17, 1127.82, 940.88, 901.011, 952.014, 855.329, 773.572, 728.226, 785.385, 827.761, 758.929, 641.364, 647.853, 627.431, 637.092, 647.254, 674.349, 713.108, 734.862, 713.598, 691.299, 667.298, 644.9, 602.8, 651.1, 697.9, 719.298, 724.699, 680.099, 685.599, 653.501, 614.499, 597.399, 571.301, 654.872, 631.89, 616.44, 600.92, 599.705, 599.686, 596.195, 591.026, 588.303, 597.374, 728.844, 863.4, 827.643, 860.783, 874.99, 882.1, 887.8, 886.8, 892.803, 885.459, 806.544, 678.188, 882.543, 914.832, 751.937, 831.814, 914.2},
 {932.212, 901.404, 840.087, 794.271, 759.802, 943.133, 1219.218, 1120.909, 972.52, 827.061, 768.948, 699.077, 710.5, 715.572, 776.117, 832.75, 718.76, 961.41, 820.21, 1065.21, 878.11, 854.99, 837.19, 835.438, 838.741, 753.777, 696.454, 734.005, 728.661, 668.089, 661.661, 611.767, 649.65, 610.92, 627.842, 700.523, 720.085, 718.813, 703.198, 686.599, 662.901, 645.302, 601.8, 644.302, 671.302, 715.602, 706.899, 709.599, 674.199, 659.201, 630.8, 597.1, 570.1, 591.05, 617.992, 595.72, 592.221, 593.183, 591.256, 579.5, 580.778, 584.028, 674.586, 744.38, 731.479, 760.001, 781.246, 873.382, 876.6, 882.8, 882.824, 889.118, 879.67, 835.229, 721.022, 887.557, 728.644, 924.095, 897.087, 878.314},
 {896.163, 855.04, 940.489, 816.382, 711.496, 939.991, 1122.227, 990.527, 765.91, 679.97, 763.513, 847.411, 866.299, 686.913, 693.14, 668.05, 697.08, 801.1, 1010.55, 894.91, 746.48, 838.15, 769.078, 771.732, 809.999, 726.34, 601.787, 704.659, 617.622, 622.49, 652.49, 634.589, 623.594, 597.541, 634.835, 705.83, 728.863, 734.681, 706.001, 697.998, 656.898, 644.199, 599.501, 636.799, 702.198, 701.002, 701.6, 711.701, 666.298, 652.1, 611.201, 595.9, 578.099, 564.201, 587.011, 586.402, 585.019, 584.877, 571.975, 779.492, 619.223, 608.957, 719.391, 695.303, 740.031, 868.165, 872.283, 875.429, 870.522, 873.857, 873.2, 877.298, 883.237, 738.653, 838.147, 704.993, 742.027, 910.845, 901.71, 936.201},
 {832.418, 817.247, 712.553, 759.551, 719.652, 857.498, 779.017, 717.101, 689.095, 662.43, 668.958, 694.923, 739.656, 694.497, 777.853, 897.2, 735.2, 900.47, 883.77, 791.45, 725.98, 734.86, 761.071, 747.71, 743.316, 667.976, 622.406, 598.885, 576.421, 626.74, 650.928, 638.153, 626.786, 601.24, 679.64, 718.461, 712.13, 704.576, 714.299, 685.799, 683.201, 636.598, 622.199, 605.8, 679.399, 676.6, 697.4, 694.4, 683.701, 656.501, 641.499, 604.3, 583.701, 560.097, 575.699, 576.371, 575.529, 564.796, 589.705, 642.408, 667.4, 654.398, 671.404, 721.213, 743.727, 859.435, 863.594, 848.791, 852.302, 861.422, 827.9, 837.252, 712.712, 873.163, 866.481, 885.959, 896.529, 917.111, 909.88, 933.938},
 {732.812, 798.422, 860.608, 783.311, 797.648, 968.254, 791.169, 675.676, 674.059, 625, 637.75, 629.15, 642.55, 716.45, 751.43, 641.6, 687.11, 910.5, 818.99, 820.77, 749.57, 687.21, 722.45, 636.77, 688.568, 588.901, 536.001, 549.448, 597.038, 629.341, 640.397, 642.331, 627.219, 587.225, 660.16, 699.099, 684.637, 700.171, 726.899, 702.301, 688.5, 673.199, 657.3, 612.5, 633.299, 655.399, 676.199, 668.4, 692.401, 691.102, 654.099, 620.601, 612.2, 563.379, 554.085, 557.412, 564.478, 600.556, 613.825, 655.636, 628.211, 660.424, 814.083, 785.293, 814.507, 802.316, 807.594, 846.562, 852.454, 851.079, 861.9, 778.68, 689.765, 857.532, 862.132, 853.961, 870.862, 874.059, 889.182, 920.951},
 {913.095, 1313.466, 1092.223, 1144.158, 1010.786, 1329.953, 1146.955, 749.956, 717.457, 664.93, 621.37, 744.94, 698.39, 677.5, 684.91, 864.17, 686.63, 706.05, 699.14, 783.6, 737.16, 686.21, 607.748, 602.35, 563.376, 548.379, 536.381, 571.319, 591.948, 624.62, 632.789, 647.221, 624.354, 582.077, 642.927, 697.059, 685.545, 694.647, 704.6, 715.5, 696.699, 659.299, 647.6, 624.698, 616.9, 623.399, 617.7, 662.5, 688.098, 684.701, 639.602, 647.9, 628.899, 592.427, 549.658, 613.474, 652.595, 644.58, 613.701, 603.34, 639.798, 654.722, 793.387, 765.077, 800.632, 813.603, 844.693, 834.265, 842.689, 851.563, 812.7, 651.6, 853.966, 814.955, 806.455, 809.178, 839.616, 872.852, 902.1, 895.289},
 {1163.216, 1617.279, 1381.549, 1190.125, 987.823, 1479.557, 1125.533, 966.429, 873.354, 769.98, 679.52, 758.24, 753.68, 694.97, 584.48, 675.24, 733.82, 627.39, 751.28, 708.06, 718.99, 682.41, 597.55, 514.104, 553.278, 527.647, 564.281, 578.939, 572.034, 605.511, 649.109, 647.539, 653.3, 579.145, 640.385, 656.329, 675.444, 686.18, 724.9, 705.202, 681.3, 674.899, 662.299, 632.5, 600.501, 573.198, 597.399, 667.401, 647.6, 666.401, 631.3, 628.099, 648.801, 619.985, 549.684, 575.838, 621.309, 580.496, 626.808, 637.31, 666.224, 728.713, 739.64, 805.819, 828.469, 829.911, 828.675, 794.7, 841.013, 847.577, 850.5, 659.8, 844.098, 806.671, 807.057, 830.909, 820.361, 884.523, 888.282, 884.792},
 {1810.914, 1949.482, 1379.941, 1107.619, 1120.265, 1440.839, 1091.83, 1143.66, 1164.93, 871.74, 657.41, 710.41, 715.18, 703.76, 667.07, 613.81, 517.59, 645.71, 675.13, 725.67, 658.8, 597.04, 544.901, 534.775, 515.992, 519.605, 561.979, 584.326, 634.215, 615.975, 656.12, 624.059, 633.092, 576.33, 638.121, 650.102, 691.371, 701.939, 711.799, 714.098, 697.199, 683.099, 670.499, 615.101, 590.601, 576.599, 606.402, 627.399, 625.698, 640.2, 637.598, 613.2, 628.202, 652.422, 544.822, 554.182, 600.473, 655.906, 685.991, 665.617, 763.203, 765.424, 807.716, 823.917, 830.178, 831.398, 837.993, 781.712, 836.19, 856.982, 839.3, 658.2, 724.157, 802.827, 797.394, 805.442, 848.065, 881.762, 816.504, 808.679},
 {1265.541, 1352.873, 1624.051, 1391.729, 1432.299, 1473.896, 1234.01, 1059.89, 758.98, 700.54, 671.78, 729.52, 688.32, 633.79, 602.96, 587, 686.76, 608.22, 658.92, 678.33, 571.29, 599.69, 535, 492.5, 552.652, 556.187, 588.075, 594.514, 614.36, 659.014, 656.514, 644.274, 622.049, 580.419, 612.238, 645.274, 685.655, 699.475, 702.6, 694.7, 672.301, 668.7, 648.699, 617.802, 607.5, 599.1, 591.2, 593.9, 621.699, 642.999, 634.201, 606.902, 609.099, 634.795, 540.789, 552.813, 580.485, 613.877, 656.701, 772.085, 771.79, 779.385, 790.703, 817.116, 819.427, 839.595, 832.623, 811.142, 841.119, 846.691, 823.9, 637, 729.704, 778.193, 816.826, 825.651, 837.551, 836.045, 811.041, 782.26},
 {835.97, 1062.29, 1309.72, 1335.56, 1330.76, 1309.34, 949.61, 759.71, 695.7, 718.69, 678.73, 829.23, 856.07, 830.05, 924.24, 802.6, 753.61, 653.45, 604.03, 674.56, 495.74, 527.07, 474.279, 540.141, 541.741, 586.92, 608.82, 621.721, 623.2, 649.19, 644.13, 647.768, 630.939, 572.788, 639.849, 641.241, 656.457, 674.952, 679.6, 698.699, 689.299, 672.601, 641.101, 617.7, 604.398, 587.299, 580.599, 596.9, 603.898, 623.6, 633.099, 641.298, 563.401, 584.386, 659.678, 538.969, 559.537, 613.083, 686.193, 732.988, 749.986, 779.915, 791.194, 798.633, 812.199, 829.995, 839.5, 841.681, 830.177, 823.895, 685.9, 668.9, 786.874, 815.402, 799.566, 813.751, 789.714, 776.915, 786.105, 761.455},
 {682.96, 1002.89, 1294.78, 1070.01, 987.18, 900.4, 829.69, 699.6, 832.23, 802.62, 786.45, 848.68, 786.7, 808.02, 815.26, 861.55, 727.12, 716.64, 675.21, 513.72, 462.21, 490.09, 556.28, 562.72, 586.4, 592.07, 599.63, 600.44, 630.9, 631.26, 670.992, 643.235, 616.709, 562.693, 618.643, 637.79, 639.574, 664.249, 671.14, 697.102, 677.801, 678.508, 644.6, 629.091, 626.814, 600.306, 587.499, 552.329, 596.724, 595.212, 618.187, 580.564, 529.871, 538.903, 594.099, 535.101, 562.101, 636, 648.701, 693.999, 786.099, 772.39, 775.222, 796.305, 795.798, 810.614, 828.408, 741.499, 721.604, 668.561, 801.6, 838.7, 756.359, 807.46, 810.192, 820.297, 794.454, 755.808, 763.382, 787.727},
 {607.6, 635.02, 674.05, 683.76, 658.67, 685.8, 918.35, 896.42, 775.45, 822.68, 827.04, 851.77, 753.69, 740.82, 774.44, 731.52, 641.91, 581.44, 523.97, 490.97, 453.98, 537.9, 523.28, 496.48, 540.43, 572.87, 584.66, 575.93, 615.11, 635.01, 673.822, 634.221, 616.966, 567.345, 634.811, 662.597, 655.358, 657.289, 652.077, 674.114, 667.608, 668.798, 663.8, 633.991, 613.317, 610.485, 604.986, 571.212, 553.872, 543.195, 539.509, 536.496, 630.995, 527.905, 530.5, 546.3, 568.799, 630.601, 664.4, 733.699, 768.599, 767.901, 781.601, 786.499, 791.299, 808.8, 819.1, 809.099, 761.5, 747.1, 799.2, 820.7, 785.6, 809.929, 797.345, 806.606, 770.478, 768.632, 727.199, 682.67},
 {607.22, 615.57, 605.85, 609.64, 665.88, 804.81, 955.16, 907.52, 1149.5, 779.12, 688.42, 715.44, 710.85, 673.7, 648.83, 596.04, 524.05, 499.34, 492.22, 474.41, 461.29, 524.08, 564.52, 568.57, 553.64, 538.99, 584.13, 606.25, 619.2, 647.69, 665.153, 644.333, 613.501, 565.761, 644.85, 641.081, 620.895, 646, 661.51, 677.748, 657.326, 638.102, 654.7, 621.291, 608.897, 595.996, 583.387, 559.725, 553.29, 560.598, 585.007, 638.712, 525.198, 525.404, 526.599, 557.301, 582.799, 666.699, 681.901, 686.099, 752.899, 770.399, 775.799, 795.699, 788.899, 801.499, 796.601, 791.899, 730.5, 804.6, 800.1, 767.5, 793.3, 794.029, 807.614, 791.486, 795.229, 768.45, 722.918, 639.158},
 {556.69, 563.16, 601.65, 640.55, 680.32, 696.42, 800.69, 981.06, 919.88, 830.62, 634.92, 655.49, 634.1, 645.02, 637.16, 541.87, 510.751, 488.59, 481.9, 448.888, 525.97, 531.16, 525.22, 560.63, 585.97, 576.21, 596.04, 595.45, 649.48, 652.3, 637.223, 619.334, 606.901, 555.425, 626.243, 616.727, 640.913, 667.588, 685.639, 682.687, 664.416, 641.773, 617.767, 614.54, 601.616, 595.839, 585.113, 590.707, 597.3, 613.505, 650.708, 621.799, 518.001, 519.503, 569.301, 641.8, 662.101, 691.999, 750.701, 743.4, 766.899, 762.499, 765.199, 785.099, 724.401, 787.977, 737.185, 734.615, 606.6, 798.4, 772.2, 786.2, 809, 780.8, 815.3, 794.323, 770.847, 743.853, 711.088, 640.352},
 {628.76, 595.48, 610.9, 622.91, 669.58, 687.01, 848.97, 780.52, 738.39, 712.62, 626.39, 618.48, 548.26, 623.64, 574.73, 538.04, 492.45, 480.84, 458.79, 467.58, 499.97, 535.28, 551.24, 542.81, 579.07, 614.06, 590.05, 632.57, 655.7, 631.14, 638.759, 595.389, 592.785, 563.288, 619.677, 615.583, 663.604, 675.543, 696.071, 676.359, 660.383, 642.627, 667.594, 616.672, 603.899, 595.586, 623.986, 624.51, 606.705, 596.118, 605.002, 589.728, 519.693, 564.507, 654.4, 638.801, 695.9, 705.601, 739.899, 746.301, 745.1, 749.199, 766, 701, 711.3, 766.489, 687.701, 599.76, 772.1, 665.7, 775, 771.9, 767.6, 801.4, 777.2, 775.519, 752.213, 712.447, 663.059, 581.15},
 {617.277, 614.569, 634.298, 676.045, 776.572, 766.592, 762.38, 800.49, 771.2, 653.28, 634.56, 574.12, 518.278, 581.636, 498.37, 507.94, 480.77, 463.18, 459.4, 515.95, 547.291, 531.241, 567.25, 578.46, 589.89, 623.79, 627.02, 629.02, 653.2, 619.98, 615.36, 607.89, 585.43, 568.25, 654.43, 660.18, 652.55, 684.482, 686.421, 663.441, 658.939, 648.892, 638.45, 616.058, 607.545, 613.325, 639.211, 613.794, 601.589, 569.097, 585.919, 522.173, 515.592, 612.198, 678.7, 698.2, 688.3, 701.3, 733.399, 746.099, 735.099, 645.301, 768.201, 579.399, 619.399, 590.818, 596.298, 636.101, 752.941, 773, 752.9, 792.5, 757.9, 742.3, 742.2, 735.441, 745.435, 719.728, 614.771, 582.158},
 {595.868, 729.446, 870.819, 948.294, 914.237, 793.761, 731.52, 654.79, 625.5, 620.04, 586.5, 473.636, 499.045, 510.427, 488.01, 459.77, 453.44, 436.16, 494.69, 532.19, 558.751, 560.579, 543.989, 603.014, 618.47, 636.653, 664.71, 654.16, 658.728, 628.19, 596.1, 603.73, 566.76, 541.39, 599.49, 627.82, 664.18, 680.076, 676.771, 654, 638.584, 630.784, 634.036, 627.078, 609.135, 627.927, 623.9, 602.196, 612.653, 596.308, 575.788, 520.782, 511.605, 602.883, 678.299, 696.2, 584.701, 563.4, 558.6, 559.099, 567.901, 567.601, 570.499, 680.4, 744.399, 775.532, 654.373, 735.787, 665.999, 749.1, 764.3, 761.4, 763.8, 665.4, 724.2, 749.631, 654.355, 706.431, 580.877, 627.976},
 {648.004, 833.285, 887.328, 789.101, 817.628, 854.179, 902.79, 799.36, 678.456, 535.51, 495.536, 442.702, 498.316, 473.335, 462.2, 440.594, 459.73, 489.74, 508.62, 545.45, 553.553, 571.995, 606.804, 589.728, 619.33, 651.013, 661.26, 638.112, 650.395, 617.82, 600.54, 602.55, 572.44, 560.72, 602.31, 644.39, 661.07, 674.171, 651.474, 646.38, 637.54, 621.53, 614.75, 618.34, 624.294, 638.783, 619.907, 648.91, 626.183, 590.709, 535.32, 511.907, 597.261, 620.297, 683.601, 625.7, 538.999, 570.6, 639.101, 646.9, 739.899, 672.301, 612.101, 755.501, 750.499, 769.925, 776.917, 768.459, 712.181, 774.4, 759.1, 769.3, 723.5, 740.6, 631.3, 653.499, 643.323, 638.371, 578.213, 625.621},
 {679.842, 821.283, 786.763, 753.484, 650.42, 715.344, 775.81, 760.16, 613.286, 478.901, 481.466, 464.751, 480.108, 457.148, 423.201, 442.456, 502.505, 495.588, 507.793, 534.052, 552.382, 588.862, 611.236, 617.189, 635.165, 635.86, 623.056, 620.293, 641.08, 617.717, 603.96, 562.57, 560.34, 599.72, 621.43, 644.54, 660.56, 672.96, 654.57, 627.74, 620.87, 612.93, 610.09, 603.66, 637.538, 638.034, 607.297, 603.603, 614.02, 604.503, 519.921, 508.087, 631.223, 659.895, 604.601, 583.6, 532.499, 574.599, 668.5, 693.901, 720.5, 654.501, 685.9, 728.7, 724.001, 680.4, 754.299, 795.699, 800.6, 750.9, 764, 757.4, 684.6, 657.8, 596.5, 609.299, 586.202, 568.861, 597.374, 610.214},
 {720.031, 704.394, 670.056, 664.543, 649.385, 627.799, 603.076, 601.227, 491.715, 475.707, 452.493, 475.863, 438.73, 425.36, 471.409, 491.716, 497.829, 535.453, 546.3, 552.701, 562.993, 575.328, 607.852, 650.565, 642.704, 634.292, 617.716, 628.211, 631.545, 615.212, 603.008, 559.329, 547.253, 604.779, 614.056, 639.064, 667.007, 651.83, 634.72, 620.15, 615.41, 613.33, 592.22, 617.79, 661.75, 619.217, 607.92, 596.594, 584.495, 584.39, 509.3, 506.211, 649.689, 615.488, 585.101, 528.5, 550.4, 634.9, 686.499, 718.5, 749.401, 618.901, 696.799, 757.999, 736.499, 714.401, 762.401, 767.201, 761.499, 726.3, 712, 735.8, 658.5, 621.3, 590.1, 560.633, 597.769, 588.517, 650.064, 638.891},
 {661.972, 653.619, 597.11, 597.729, 598.436, 514.442, 508.549, 465.774, 453.765, 433.405, 440.747, 416.685, 447.369, 472.04, 449.231, 486.321, 534.583, 558.529, 572.477, 590.354, 575.628, 578.898, 628.013, 629.922, 629.403, 632.053, 623.19, 623.581, 610.579, 598.951, 585.577, 550.466, 551.363, 607.249, 625.355, 660.447, 657.249, 631.967, 627.41, 605.35, 593.4, 597.98, 595.35, 629.11, 692.05, 632.798, 625.841, 604.237, 591.076, 553.646, 505.8, 499.692, 572.524, 548.039, 518.798, 520.104, 611.906, 650.285, 697.402, 770.812, 751.106, 723.317, 753.8, 767.106, 782.496, 747.288, 769.698, 732.294, 741.305, 726.464, 652.5, 669.9, 623.7, 596.7, 594.9, 608, 603.158, 662.152, 698.051, 709.09},
 {597.721, 581.484, 527.416, 479.441, 465.372, 457.357, 467.722, 451.568, 445.568, 442.539, 428.362, 448.711, 458.332, 483.648, 487.599, 494.011, 516.624, 522.103, 555.803, 577.821, 609.037, 602.193, 626.253, 623.749, 639.279, 623.11, 609.275, 629.812, 582.803, 580.517, 560.484, 518.985, 559.177, 616.022, 655.589, 658.826, 634.259, 621.788, 594.74, 592.52, 576.24, 585.61, 604.45, 694.6, 662.98, 676.84, 649.06, 608.92, 595, 509.36, 501.5, 555.534, 531.529, 512.585, 549.748, 619.955, 644.331, 724.849, 732.508, 780.591, 748.791, 713.002, 753.8, 758.829, 759.828, 783.003, 747.492, 708.372, 745.208, 670.601, 641.9, 634.2, 582.8, 554.2, 558.3, 601.3, 642.3, 674.346, 677.749, 719.487},
 {659.485, 548.438, 465.11, 432.63, 475.173, 421.708, 453.184, 428.104, 434.572, 444.876, 465.01, 471.912, 485.271, 502.813, 537.799, 551.133, 549.173, 565.447, 583.698, 588.021, 619.844, 613.813, 625.974, 597.495, 639.468, 610.579, 600.922, 595.934, 584.419, 567.289, 516.506, 572.084, 609.295, 612.801, 635.738, 635.047, 614.333, 607.779, 586.395, 574.972, 550.99, 577.77, 619.43, 678, 631.64, 672.06, 631.14, 615.18, 603.61, 502.61, 496.5, 502.711, 508.174, 582.165, 633.972, 622.789, 652.203, 677.209, 773.976, 774.203, 756.914, 719.101, 741.2, 763.3, 761.7, 750.6, 722.5, 726.2, 689.6, 665.3, 589.9, 547.7, 550.7, 577.3, 573.2, 592.7, 628.3, 675.699, 683.824, 711.253},
 {487.505, 445.951, 425.131, 438.522, 454.805, 442.16, 452.391, 412.157, 432.997, 469.798, 479.395, 493.281, 490.033, 512.773, 532.969, 550.843, 558.649, 569.822, 576.969, 600.629, 614.51, 615.572, 610.679, 603.11, 619.286, 590.559, 582.494, 590.235, 574.285, 547.601, 551.977, 599.451, 595.958, 656.428, 645.969, 611.771, 609.915, 579.077, 574.985, 585.731, 555.945, 595.97, 644.223, 661.387, 623.529, 621.137, 619.34, 581.25, 511.17, 495.915, 511.7, 599.545, 611.747, 635.381, 655.785, 654.296, 750.3, 722.265, 775.271, 768.826, 767.705, 773.286, 768.5, 701.8, 730.6, 712.2, 700.1, 647.3, 656, 626.3, 562, 561.6, 576.2, 594.4, 608.9, 632.1, 657, 678.524, 644.031, 702.239},
 {437.905, 433.401, 398.162, 437.862, 445.932, 437.92, 426.549, 402.394, 452.792, 467.111, 485.968, 463.634, 517.99, 528.417, 536.537, 530.633, 557.653, 565.38, 571.358, 577.26, 593.713, 575.338, 594.779, 578.799, 590.761, 593.991, 566.228, 577.539, 559.087, 528.004, 581.364, 611.658, 641.814, 631.932, 613.942, 589.801, 581.881, 544.429, 570.489, 557.342, 570.502, 601.845, 644.41, 624.762, 619.122, 613.245, 616.21, 571.58, 496.24, 494.193, 544.5, 599.316, 602.864, 606.975, 618.123, 631.513, 645.098, 657.855, 674.686, 701.3, 766.999, 768.6, 718.4, 661.2, 663.7, 653.3, 663, 630.3, 621.4, 556.4, 540.3, 588.2, 606.5, 621.3, 629.3, 612.2, 665.4, 712.39, 715.555, 698.319},
 {434.368, 406.653, 400.929, 396.2, 421.666, 430.75, 393.79, 412.293, 442.769, 487.122, 439.878, 473.152, 491.301, 501.295, 505.824, 531.998, 546.678, 552.673, 555.725, 581.647, 582.25, 573.578, 579.489, 581.611, 590.479, 579.151, 560.969, 567.448, 542.819, 502.941, 591.432, 607.675, 632.279, 606.419, 595.01, 578.424, 545.283, 531.276, 553.81, 554.978, 546.959, 587.827, 637.135, 614.325, 614.956, 608.615, 603.17, 585.91, 479.88, 496.975, 573.4, 588.5, 579.2, 568.481, 610.7, 619.3, 625.4, 612.5, 648.1, 761.4, 661.4, 755.3, 665, 648.5, 633.4, 622.2, 637.8, 583.4, 552.353, 535.375, 609.7, 628.1, 630.8, 641.2, 667.4, 653, 675.3, 743.949, 771.492, 828.423},
 {415.235, 386.092, 423.626, 436.54, 441.301, 436.323, 458.892, 458.175, 450.025, 434.334, 437.639, 450.002, 451.3, 461.191, 508.516, 511.895, 522.402, 551.787, 580.547, 592.063, 589.977, 570.37, 554.752, 566.23, 554.589, 564.348, 555.429, 552.308, 535.238, 538.977, 553.037, 597.765, 617.686, 603.299, 564.521, 555.795, 518.877, 515.858, 540.791, 549.62, 549.798, 621.075, 622.69, 615.129, 598.079, 559.732, 599.788, 503.405, 483.278, 515.806, 541.747, 527.915, 521.464, 518.5, 531.3, 580.1, 574.7, 590.8, 627.6, 623.2, 613.7, 606.6, 616.6, 612.4, 593.8, 562.7, 550.6, 525.978, 541.779, 616.7, 654.6, 658.2, 678.6, 690, 704.2, 685.3, 645.1, 747.543, 760.037, 806.171},
 {390.361, 413.128, 442.322, 445.801, 419.49, 458.891, 462.262, 463.876, 471.078, 475.088, 477.32, 481.466, 479.676, 480.741, 495.831, 514.038, 534.163, 564.99, 587.78, 579.732, 592.429, 581.598, 564.779, 547.388, 571.519, 553.471, 552.558, 550.951, 531.608, 497.64, 548.184, 589.55, 601.181, 592.459, 556.561, 545.125, 514.748, 507.428, 533.137, 514.87, 563.623, 624.441, 593.416, 609.882, 564.413, 511.643, 564.837, 480.898, 487.134, 489.983, 491.038, 495.332, 497.664, 498.7, 501.2, 506.7, 509, 517.9, 520.2, 515, 532.9, 545.8, 544, 535.9, 525.267, 529.176, 539.357, 598.068, 638.2, 656.2, 670.4, 634.1, 695.2, 734.1, 747.9, 775.567, 678.027, 677.702, 767.251, 740.472},
 {440.049, 420.431, 429.011, 455.294, 454.52, 429.941, 446.125, 448.849, 456.897, 469.63, 480.186, 503.671, 516.031, 507.653, 514.475, 533.88, 545.808, 571.409, 568.629, 568.398, 577.039, 560.739, 559.58, 532.177, 563.102, 559.197, 528.986, 530.57, 528.109, 503.131, 525.349, 540.521, 561.812, 558.001, 541.801, 518.034, 521.631, 511.051, 508.258, 514.782, 600.319, 613.078, 613.394, 526.963, 575.429, 517.26, 486.624, 484.402, 486.669, 491.942, 504.984, 544.789, 601.225, 585.5, 548.7, 563.7, 551.9, 526.4, 557.9, 513.5, 544.6, 518.243, 536.55, 522.711, 573.53, 608.055, 632.188, 637.566, 613.556, 688.821, 714.971, 668.351, 706.206, 794.609, 813.696, 776.983, 715.508, 719.626, 695.169, 709.672},
 {449.338, 458.321, 436.674, 453.649, 474.558, 458.399, 462.582, 475.452, 482.69, 481.766, 507.071, 503.45, 528.411, 529.206, 544.418, 549.427, 565.353, 554.568, 550.359, 538.095, 559.723, 549.697, 550.338, 519.518, 532.745, 544.88, 539.492, 515.404, 510.319, 506.533, 497.757, 526.469, 540.659, 554.674, 528.431, 535.394, 517.372, 494.528, 508.5, 529.049, 596.279, 630.346, 595.851, 506.728, 531.48, 478.403, 482.794, 486.594, 530.105, 544.7, 600.723, 588.215, 612.485, 616.9, 629.3, 616.7, 619.888, 647.564, 625.646, 602.78, 631.581, 656.812, 614.358, 607.295, 623.276, 655.879, 663.42, 655.227, 656.566, 674.298, 704.025, 690.188, 782.259, 773.165, 813.448, 770.345, 792.244, 810.802, 734.984, 778.952},
 {466.68, 464.33, 456.22, 485.44, 490.06, 483.74, 472.11, 495.831, 519.647, 506.622, 544.048, 540.158, 536.552, 538.581, 541.981, 544.952, 544.281, 536.184, 555.158, 517.125, 532.811, 553.05, 547.096, 506.389, 510.411, 521.582, 517.661, 492.168, 511.14, 495.929, 495.839, 547.183, 554.196, 518.044, 519.721, 577.367, 532.89, 497.592, 493.151, 532.057, 599.878, 611.499, 534.136, 502.14, 479.79, 482.243, 519.397, 555.754, 556.572, 621.714, 613.122, 623.652, 619.311, 705.97, 732.87, 658.295, 661.994, 622.552, 741.527, 633.085, 729.628, 712.086, 664.181, 645.122, 636.782, 661.912, 711.911, 694.977, 723.447, 701.772, 708.361, 721.499, 752.952, 782.149, 821.662, 808.469, 827.258, 815.848, 809.084, 805.232},
 {466.262, 482.12, 475.98, 463.42, 491.8, 484.18, 504.87, 498.23, 534.85, 540.68, 532.74, 562.96, 566.48, 564.95, 562.63, 551.65, 542.38, 523.11, 511.92, 508.847, 523.18, 556.65, 538.1, 509.78, 486.91, 496.09, 513.19, 482.23, 482.23, 499.151, 529.481, 518.7, 506.74, 495.61, 509.741, 546.509, 517.32, 483.561, 484.914, 506.041, 564.586, 587.78, 489.895, 477.812, 477.305, 495.003, 550.21, 576.735, 549.852, 587.413, 619.696, 604.543, 654.767, 726.924, 726.61, 733.16, 738.778, 686.18, 737.51, 729, 751.85, 732.39, 655.871, 718.42, 713.81, 661.25, 720.26, 734.11, 739.1, 740.24, 775.16, 790.73, 802.21, 810.65, 803.13, 800.09, 803.68, 808.53, 792.35, 794.19},
 {401.41, 436.3, 447.53, 483.38, 499.17, 522.01, 541.47, 541.48, 549.68, 566.5, 560.14, 565.406, 560.86, 553.62, 576.78, 564.4, 538.67, 523.65, 509.76, 491.9, 497.56, 497.15, 541.04, 498.48, 486.93, 474.72, 506.02, 467.74, 498.15, 512.011, 519.109, 512.33, 494.811, 488.51, 489.45, 501.86, 488.91, 477.41, 476.879, 476.972, 480.691, 478.203, 474.62, 475.874, 528.6, 539.209, 532.83, 549.781, 580.248, 615.476, 624.599, 649.249, 637.547, 721.423, 724.95, 735.143, 736.594, 743.14, 745.08, 733.3, 754.2, 730.99, 732.95, 746.66, 727.27, 693.089, 738.48, 752.39, 786.861, 794.09, 785.32, 785.24, 798.52, 799.78, 791.38, 791.27, 800.01, 796.74, 763.06, 819.31},
 {382.92, 382.83, 393.88, 415.48, 500.68, 538.76, 547.82, 559.32, 584.41, 585.93, 574.74, 555.69, 544.41, 539.52, 555.32, 555.861, 542.42, 513.82, 490.03, 478.49, 493.385, 487.38, 504.89, 505.51, 471.17, 454.42, 458.53, 463.09, 510.67, 546.771, 551.25, 547.529, 522.481, 493.72, 479.21, 475.246, 476.689, 472.259, 473.328, 466.051, 471.418, 472.981, 472.725, 535.08, 529.045, 548.612, 585.285, 614.455, 618.009, 613.647, 710.381, 713.741, 706.215, 725.021, 733.12, 734.616, 736.99, 740.73, 746.519, 750.1, 752.21, 752.47, 754.931, 769.135, 768.14, 735.9, 769.46, 786.76, 790.39, 774.16, 777.78, 784.16, 797.88, 789.3, 782.55, 796.59, 809.55, 758.18, 798.839, 788.43},
 {408.23, 385.89, 386.21, 390.91, 419.99, 525.71, 533.27, 506.15, 546.9, 552.29, 565.61, 538.59, 513.23, 516.53, 571.97, 547.96, 533.41, 524.99, 493.6, 493.84, 499.15, 475.03, 489.18, 489.43, 450.74, 521.44, 532.88, 537.41, 570.91, 606.28, 615.26, 595.989, 537.651, 504.64, 478.779, 476.81, 467, 463.51, 466.295, 470.953, 486.923, 491.614, 513.101, 566.927, 571.228, 594.037, 662.937, 679.683, 704.959, 710.433, 662.837, 715.166, 719.715, 726.888, 730.23, 734.5, 740.532, 734.39, 740.341, 739.04, 745.179, 744.216, 753.54, 764.55, 761.07, 773.09, 778.84, 778.69, 776.65, 776.15, 789.57, 792.8, 796.521, 781.15, 795.81, 790.41, 778.04, 770.76, 790.77, 795.71},
 {450.77, 438.21, 397.65, 398.24, 388.71, 430.02, 441.35, 467.91, 535.9, 508.84, 548.7, 517.54, 496.84, 543.17, 576.71, 541.461, 523.42, 526.171, 507.2, 474.45, 513.54, 475.82, 454.95, 445.583, 510.37, 561.161, 595.91, 608.65, 570.8, 606.8, 585.49, 585.92, 567.62, 517.43, 492.08, 468.76, 464.59, 465.288, 481.554, 502.889, 527.814, 538.472, 532.289, 602.598, 679.974, 685.3, 678.809, 693.756, 705.57, 706.868, 709.651, 712.412, 716.793, 719.27, 727.21, 720.057, 732.134, 737.359, 738.361, 735.76, 743.026, 743.16, 748.81, 749.83, 753.329, 761.359, 769.52, 772.73, 765.482, 770.07, 788.69, 779.97, 791.3, 767.41, 791.07, 792.14, 754.53, 774.53, 780.599, 773.07},
 {465.23, 431.07, 426.74, 402.53, 396.87, 392.48, 397.08, 424.76, 495.36, 491.13, 513.61, 485.3, 496.66, 552.181, 540.289, 534.879, 504.069, 544.761, 523.429, 490.71, 506.24, 474.21, 475.7, 445.88, 489.14, 543.79, 565.42, 561.89, 548.969, 571.57, 613.84, 549.43, 508.92, 473.42, 462.53, 462.58, 486.281, 490.39, 515.725, 527.443, 513.929, 492.574, 529.808, 548.431, 593.653, 605.159, 601.187, 692.429, 702.087, 702.295, 704.87, 708.788, 713.809, 717.761, 720.08, 724.77, 729.891, 727.65, 724.13, 739.91, 741.718, 744.49, 741.85, 744.54, 749.95, 758.799, 758.744, 762.91, 758.26, 776.65, 773.57, 775.94, 776.02, 789.84, 784.33, 770.55, 742.46, 775.27, 764.76, 798.259},
 {458.69, 411.94, 452.74, 452.24, 438.66, 423.79, 395.2, 413.25, 457.62, 477.2, 485.64, 460.95, 524.08, 525.35, 546.998, 497.091, 503.74, 559.539, 527.771, 484.339, 457.659, 436.77, 433.7, 435.691, 452.801, 507.92, 541.54, 513.189, 497.819, 524.211, 548.33, 497.83, 459.14, 459.62, 476.03, 486.46, 488.13, 478.678, 543.497, 551.55, 559.978, 534.091, 502.74, 521.59, 544.348, 602.339, 640.371, 690.005, 699.252, 700.591, 703.278, 710.388, 710.619, 713.062, 715.64, 720.11, 715.02, 728.3, 731.849, 734.87, 742.5, 720.06, 731.25, 747.43, 741.33, 755.67, 752.58, 754.29, 760.48, 770.7, 763.78, 760.46, 753.2, 772.22, 763.79, 768.93, 755.45, 763.52, 775.55, 789.549},
 {461.68, 468.85, 463.64, 460.36, 457.63, 450.9, 405.5, 403.67, 426.43, 476.99, 444.99, 457.75, 469.63, 483.61, 517.709, 499.929, 493.649, 434.529, 501.809, 436.94, 431.51, 425.68, 508.18, 492.851, 476.43, 447.35, 441.61, 443.533, 442.671, 480.72, 459.23, 457.09, 457.599, 480.109, 500.88, 515.6, 488.54, 513.229, 483.221, 572.179, 581.56, 567.9, 545.866, 517.698, 519.73, 540.852, 592.923, 603.46, 663.824, 633.28, 644.368, 639.698, 674.917, 699.16, 681.12, 722.09, 720.45, 729.26, 732.09, 720.11, 714.34, 701.98, 736.26, 712.83, 736.85, 756.638, 755.78, 761.38, 757.46, 759.8, 752.04, 759.3, 761.62, 754.88, 765.07, 756.29, 753.44, 756.23, 783.2, 783.49}
 };
 

    boolean candidates[][] = nBorrar(heights, errorAltura);

    //actualizamos las alturas que puedan borrarse dandoles el valor -1.0
    update(heights, candidates);


    //creamos el array de puntos, de la clase Punto
    Punto[][] points = new Punto[heights.length][heights[0].length];

    //Lo rellenamos con null o el punto segun haya sido "borrado" o no
    for (int i = 0; i < heights.length; i++)
    {
      for (int j = 0; j < heights[i].length; j++)
      {
        if (heights[i][j] == -1)
          points[i][j] = null;
        else
          points[i][j] = new Punto(distanciaEntrePuntos*j, distanciaEntrePuntos*i, heights[i][j]);
        //notese que la j va en el primer argumento y la i en el segundo (representar graficamente el array para ver por que, aunque se podria cambiar y daria igual, creo)
        //se multiplica por 100 ya que para el ejemplo se considera que los puntos estan separados 10 unidades en la cuadricula.
      }
    }

    //Una vez tenemos ya el array de puntos, hay que crear una primera triangulacion, meterla en el DCEL, programar el metodo que termina la triangulacion y flipar las aristas.

    //Procedemos a crear una primera triangulacion
    int maxaristas = 6*heights.length*heights[0].length - 12; //por el teorema 1 de euler, pero teniendo en cuenta que cada arista aqui es doble
    Arista[] a = new Arista[maxaristas];
    int maxcaras = 2 + maxaristas - heights.length*heights[0].length; //por la formula de euler
    Cara[] c = new Cara[maxcaras];

    a[0] = new Arista();
    a[1] = new Arista();
    a[2] = new Arista();
    a[3] = new Arista();
    a[4] = new Arista();
    a[5] = new Arista();

    c[0] = new Cara();
    c[1] = new Cara();

    c[0].numCara = 0;
    c[1].numCara = 1;

    //Notese que siempre hay que llevar los mismos pasos para la adicion de una cara nueva, asi que a continuacion se explica el metodo
    //La cara 0 es la exterior, el resto se van nombrando en orden incremental.
    a[0].origen = points[1][0];
    a[0].gemela = a[1];
    a[0].anterior = a[5];
    a[0].siguiente = a[2];
    a[0].cara = c[0];

    a[1].origen = points[0][0];
    a[1].gemela = a[0];
    a[1].anterior = a[3];
    a[1].siguiente = a[4];
    a[1].cara = c[1];

    a[2].origen = points[0][0];
    a[2].gemela = a[3];
    a[2].anterior = a[0];
    a[2].siguiente = a[5];
    a[2].cara = c[0];

    a[3].origen = points[0][1];
    a[3].gemela = a[2];
    a[3].anterior = a[4];
    a[3].siguiente = a[1];
    a[3].cara = c[1];

    a[4].origen = points[1][0];
    a[4].gemela = a[5];
    a[4].anterior = a[1];
    a[4].siguiente = a[3];
    a[4].cara = c[1];

    a[5].origen = points[0][1];
    a[5].gemela = a[4];
    a[5].anterior = a[2];
    a[5].siguiente = a[0];
    a[5].cara = c[0];

    c[0].arista = a[0];
    c[1].arista = a[1];


    //Usaremos 5 aristas internamente (punteros) para saber sobre cual hay que "pegar" un triangulo.

    Arista ac1, ac2, arauxsup, arauxinf, sigcasoprim;
    ac1 = a[5];
    arauxsup = a[2];
    sigcasoprim = a[0];
    arauxinf = a[0];
    ac2 = null;

    //Tambien usaremos unas variables de tipo int para ir moviendonos por los niveles

    int aux1, aux2;
    aux1 = 1;
    aux2 = 0;

    /*
     * Creamos unas variables que nos llevaran la cuenta del numero de aristas/caras y tambien nos serviran para rellenar sus
     * correspondientes arrays
     */
    int nextarista, nextcara;
    nextarista = 6;
    nextcara = 2;

    //Para cada fila
    for (int i = 1; i < points.length; i++)
    {

      //SI NO ESTAMOS EN EL CASO i=1, HABRA QUE INICIALIZAR UN PEQUEÑO TRIANGULILLO PARA EMPEZAR A TRABAJAR DESDE EL.
      //actualizar sigcasoprim y muchas cosas.
      //CASO C3
      if (i != 1)
      { //TODO
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-4
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-3
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-2
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-1

        c[nextcara] = new Cara(); 
        nextcara++; //en la posicion nextcara-1
        c[nextcara-1].numCara = nextcara - 1;

        //Inicializamos las aristas
        a[nextarista-4].origen = points[i][0];
        a[nextarista-4].gemela = a[nextarista-3];
        a[nextarista-4].anterior = a[nextarista-1];
        a[nextarista-4].siguiente = sigcasoprim;
        a[nextarista-4].cara = c[0];

        a[nextarista-3].origen = points[i-1][0];
        a[nextarista-3].gemela = a[nextarista-4];
        a[nextarista-3].anterior = ac2;
        a[nextarista-3].siguiente = a[nextarista-2];
        a[nextarista-3].cara = c[nextcara-1];

        a[nextarista-2].origen = points[i][0];
        a[nextarista-2].gemela = a[nextarista-1];
        a[nextarista-2].anterior = a[nextarista-3];
        a[nextarista-2].siguiente = ac2;
        a[nextarista-2].cara = c[nextcara-1];

        a[nextarista-1].origen = points[i-1][nextP(points[i-1], 0)];
        a[nextarista-1].gemela = a[nextarista-2];
        a[nextarista-1].anterior = ac2.anterior;
        a[nextarista-1].siguiente = a[nextarista-4];
        a[nextarista-1].cara = c[0];

        c[nextcara-1].arista = a[nextarista-3];

        //Actualizamos valores de siguiente, anterior... que hayan cambiado
        ac2.cara = c[nextcara-1];
        ac2.anterior = a[nextarista-2];
        ac2.siguiente = a[nextarista-3];
        a[nextarista-4].siguiente.anterior = a[nextarista-4];
        a[nextarista-1].anterior.siguiente = a[nextarista-1];

        //actualizamos valores para poder seguir construyendo
        ac1 = a[nextarista-1];
        sigcasoprim = a[nextarista-4];
        aux1 = nextP(points[i-1], 0);
        aux2 = 0;
        arauxinf = a[nextarista-4];
        arauxsup = a[nextarista-2].siguiente;
      }


      //Si es la primera fila, es especial ya que tambien hay que crear el "techo".
      //mientras estemos en la parte superior, cada vez que no hayamos llegado al final, hay que crear 4 aristas (para cada triangulo)
      //y una cara
      //CASO C1
      if (i == 1) 
      { //TODO
        while (aux1 != points[i-1].length-1)
        {

          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-4
          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-3
          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-2
          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-1

          c[nextcara] = new Cara(); 
          nextcara++; //en la posicion nextcara-1
          c[nextcara-1].numCara = nextcara - 1;

          //de estas 4 aristas, 2 saldran del punto siguiente al aux1, 1 saldra de 
          //origen de critica, y la otra de origen de siguiente de critica
          a[nextarista-4].origen = points[i-1][aux1];
          a[nextarista-4].gemela = a[nextarista-3];
          a[nextarista-4].anterior = arauxsup;
          a[nextarista-4].siguiente = a[nextarista-1];
          a[nextarista-4].cara = c[0];

          a[nextarista-3].origen = points[i-1][nextP(points[i-1], aux1)];
          a[nextarista-3].gemela = a[nextarista-4];
          a[nextarista-3].anterior = a[nextarista-2];
          a[nextarista-3].siguiente = ac1;
          a[nextarista-3].cara = c[nextcara-1];

          a[nextarista-2].origen = points[i][0];
          a[nextarista-2].gemela = a[nextarista-1];
          a[nextarista-2].anterior = ac1;
          a[nextarista-2].siguiente = a[nextarista-3];
          a[nextarista-2].cara = c[nextcara-1];

          a[nextarista-1].origen = points[i-1][nextP(points[i-1], aux1)];
          a[nextarista-1].gemela = a[nextarista-2];
          a[nextarista-1].anterior = a[nextarista-4];
          a[nextarista-1].siguiente = sigcasoprim;
          a[nextarista-1].cara = c[0];

          c[nextcara-1].arista = a[nextarista-3];

          //Ahora, corregimos los valores de aquellas aristas que necesitan cambiar para mantener la est DCEL
          ac1.cara = c[nextcara-1];
          ac1.anterior = a[nextarista-3];
          ac1.siguiente = a[nextarista-2];
          a[nextarista-4].anterior.siguiente = a[nextarista-4];
          a[nextarista-1].siguiente.anterior = a[nextarista-1];

          //al terminar, hay que actualizar aux1, arista critica, arauxsup.
          ac1 = a[nextarista-1];
          arauxsup = a[nextarista-4];
          aux1 = nextP(points[i-1], aux1);
        }
      }

      //si no es la primera fila, solo hay que ir creando dos aristas cada vez en la parte de arriba ya que el techo ya lo tenemos del "piso" anterior
      //CASO C4
      if (i != 1)
      { //TODO
        while (aux1 != points[i-1].length-1)
        {
          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-2
          a[nextarista] = new Arista(); 
          nextarista++; //en la posicion nextarista-1

          c[nextcara] = new Cara(); 
          nextcara++; //en la posicion nextcara-1
          c[nextcara-1].numCara = nextcara - 1;

          a[nextarista-2].origen = points[i][0];
          a[nextarista-2].gemela = a[nextarista-1];
          a[nextarista-2].anterior = ac1;
          a[nextarista-2].siguiente = ac1.anterior;
          a[nextarista-2].cara = c[nextcara-1];

          a[nextarista-1].origen = points[i-1][nextP(points[i-1], aux1)];
          a[nextarista-1].gemela = a[nextarista-2];
          a[nextarista-1].anterior = ac1.anterior.anterior;
          a[nextarista-1].siguiente = sigcasoprim;
          a[nextarista-1].cara = c[0];

          c[nextcara-1].arista = a[nextarista-2];

          //Actualizar aristas que han cambiado valores de siguiente...
          ac1.cara = c[nextcara-1];
          ac1.anterior.cara = c[nextcara-1];
          ac1.siguiente = a[nextarista-2];
          ac1.anterior.anterior = a[nextarista-2];
          a[nextarista-1].siguiente.anterior = a[nextarista-1];
          a[nextarista-1].anterior.siguiente = a[nextarista-1];

          //Actualizar cosas auxiliares
          if (nextP(points[i-1], aux1) == points[i-1].length-1)
          {
            arauxsup = a[nextarista-1].anterior;
          }
          else
          {
            arauxsup = a[nextarista-2].siguiente;
          }

          aux1 = nextP(points[i-1], aux1);
          ac1 = a[nextarista-1];
        }
      }



      //mientras estemos en la parte inferior, cada vez que no hayamos llegado al final, hay que crear 4 aristas (para cada triangulo)
      //y una cara
      //CASO C2
      while (aux2 != points[i].length-1)
      { //TODO
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-4
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-3
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-2
        a[nextarista] = new Arista(); 
        nextarista++; //en la posicion nextarista-1

        c[nextcara] = new Cara(); 
        nextcara++; //en la posicion nextcara-1
        c[nextcara-1].numCara = nextcara - 1;

        //Inicializacion de las aristas
        a[nextarista-4].origen = points[i][nextP(points[i], aux2)];
        a[nextarista-4].gemela = a[nextarista-3];
        a[nextarista-4].anterior = a[nextarista-1];
        a[nextarista-4].siguiente = arauxinf;
        a[nextarista-4].cara = c[0];

        a[nextarista-3].origen = points[i][aux2];
        a[nextarista-3].gemela = a[nextarista-4];
        a[nextarista-3].anterior = ac1;
        a[nextarista-3].siguiente = a[nextarista-2];
        a[nextarista-3].cara = c[nextcara-1];

        a[nextarista-2].origen = points[i][nextP(points[i], aux2)];
        a[nextarista-2].gemela = a[nextarista-1];
        a[nextarista-2].anterior = a[nextarista-3];
        a[nextarista-2].siguiente = ac1;
        a[nextarista-2].cara = c[nextcara-1];

        a[nextarista-1].origen = points[i-1][points[i-1].length-1];
        a[nextarista-1].gemela = a[nextarista-2];
        a[nextarista-1].anterior = arauxsup;
        a[nextarista-1].siguiente = a[nextarista-4];
        a[nextarista-1].cara = c[0];

        c[nextcara-1].arista = a[nextarista-3];

        //Actualizar valores que necesiten ser modificados
        ac1.cara = c[nextcara-1];
        ac1.anterior = a[nextarista-2];
        ac1.siguiente = a[nextarista-3];
        a[nextarista-1].anterior.siguiente = a[nextarista-1];
        a[nextarista-4].siguiente.anterior = a[nextarista-4];


        //si es el primer caso, al terminar marcar la segunda critica
        if (aux2 == 0)
        {
          ac2 = a[nextarista-4];
        }

        ac1 = a[nextarista-1];
        arauxinf = a[nextarista-4];
        aux2 = nextP(points[i], aux2);
      }
    }
    //fin de la creacion de DCEL

    /*
    int ar = 6;
     System.out.println("Triangulacion creada");
     System.out.print("actual: " + a[ar].origen.x + " ");
     System.out.println(a[ar].origen.y);
     System.out.print("siguiente: " + a[ar].siguiente.origen.x + " ");
     System.out.println(a[ar].siguiente.origen.y);
     */
    /*
    System.out.println(a[15].origen.x);
     System.out.println(a[14].siguiente.origen.y);
     System.out.println(a[47].siguiente == a[48]);
     System.out.println(a[14].gemela == a[15]);
     System.out.println(a[70].anterior == a[73]);
     */

    flip(a, c);
    aristas = a;
    caras = c;
    numeroDeColumnas = points[0].length;
    numeroDeFilas = points.length;
  }
}

class Punto
{
  double x, y, z;
  Punto(double x, double y, double z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Arista
{
  Punto origen;
  Arista gemela, anterior, siguiente;
  Cara cara;

  Arista() {
  }

  Arista(Punto origen, Arista gemela, Arista anterior, Arista siguiente, Cara cara)
  {
    this.origen = origen;
    this.gemela = gemela;
    this.anterior = anterior;
    this.siguiente = siguiente;
    this.cara = cara;
  }
}

//Cada cara tiene un atributo numCara, que coincide con la posicion del array de caras en la que se encuentra,
//y que la usamos mas que nada para actualizar bien las caras en el flip
class Cara
{
  Arista arista;
  int numCara;

  Cara() {
  }

  Cara(Arista arista, int numCara)
  {
    this.arista = arista;
    this.numCara = numCara;
  }
}