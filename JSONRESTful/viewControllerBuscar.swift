import UIKit

class viewControllerBuscar: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var peliculas = [Peliculas]()
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    // PARA EDITAR USUARIOS
    var user:Users? = nil
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/peliculas?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")

        if nombre.isEmpty{
            let ruta = "http://localhost:3000/peliculas/"
            self.cargarPeliculas(ruta:ruta){
                self.tablaPeliculas.reloadData()
            }
        }else{
            cargarPeliculas(ruta:crearURL){
                if self.peliculas.count <= 0 {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para: \(nombre)",accion:"cancel")
                }else{
                    self.tablaPeliculas.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero:\(peliculas[indexPath.row].genero) Duracion:\(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
        
        print(self.user!.nombre)
        print(self.user!.email)
    }
    
    func cargarPeliculas(ruta: String, completed: @escaping () -> ()){
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!){ (data, response, error) in
            if error == nil{
                do{
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                }catch{
                    print("Error en JSON")
                }
            }
        }.resume()
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOk = UIAlertAction(title:accion,style:.default,handler: nil)
        alerta.addAction(btnOk)
        present(alerta, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let pelicula = peliculas[indexPath.row]
           performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar"{
            let siguienteVC = segue.destination as! viewControllerAgregar
            siguienteVC.pelicula = sender as? Peliculas
        } else if segue.identifier == "segueEdicionPerfil" {
            let siguienteVC = segue.destination as! viewControllerEditarPerfil
            siguienteVC.usuario = sender as? Users
        }
    }
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let nombre_pela = peliculas[indexPath.row].nombre
            let alerta = UIAlertController(title: "Eliminar Pelicula", message: "Esta a punto de eliminar la pelicula  \(nombre_pela), ¿desea continuar?", preferredStyle: .alert)
            let btnOK = UIAlertAction(title: "Eliminar", style: .default, handler: { (UIAlertAction) in
                let id_elemento = self.peliculas[indexPath.row].id
                let ruta = "http://localhost:3000/peliculas/\(id_elemento)"
                let url:URL = URL(string: ruta)!
                var request = URLRequest(url: url)
                let session = URLSession.shared
                request.httpMethod = "DELETE"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")

                let task = session.dataTask(with: request, completionHandler: {(data,respomse,error) in
                    if(data != nil){
                        do{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                            print(dict)
                        }catch{}
                    }
                })
                task.resume()
                self.peliculas.remove(at: indexPath.row)
                self.tablaPeliculas.reloadData()
            })
            
            let btnCANCEL = UIAlertAction(title: "Cancelar", style: .default)
            alerta.addAction(btnCANCEL)
            alerta.addAction(btnOK)
            self.present(alerta, animated: true, completion: nil)
        }
    }
    
    @IBAction func botonEditarPerfil(_ sender: Any) {
        //print(self.user!.nombre)
        //print(self.user!.email)
        performSegue(withIdentifier: "segueEdicionPerfil", sender: user)
    }
}
