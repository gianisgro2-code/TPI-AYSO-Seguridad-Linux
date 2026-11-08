# Seguridad en Sistemas Operativos

Trabajo Práctico Integrador de Arquitectura y Sistemas Operativos, UTN.

**Alumno:** Gianluca Agustín Isgro  
**Docente:** Nicolás Emanuel Llaneza  
**Comisión:** 7  
**Tema:** usuarios, permisos y protección de archivos en Linux.

## Video explicativo

[Ver el video en YouTube](https://youtu.be/Po9XZzrvqaM)

## Materiales de entrega

- [Informe técnico en PDF](informe/TPI_Seguridad_Isgro.pdf)
- [Informe editable en Word](informe/TPI_Seguridad_Isgro.docx)
- [Presentación PowerPoint](presentacion/TPI_Seguridad_Isgro_Presentacion.pptx)
- [Script de la práctica](scripts/practica.sh)
- [Capturas originales de las pruebas](evidencias/capturas/)

## Práctica realizada

La práctica se ejecutó en Google Cloud Shell el 8 de noviembre de 2026. Se comparó el acceso a un archivo ficticio desde el propietario y una cuenta local temporal.

| Configuración | Resultado observado |
| --- | --- |
| Archivo 644 | La otra cuenta pudo leer |
| Archivo 600 | El propietario leyó y la otra cuenta no pudo leer ni escribir |
| Lectura administrativa | sudo permitió leer el archivo |
| Archivo 640 y grupo autorizado | El grupo pudo leer y no pudo escribir |
| Archivo 644 y directorio 700 | El directorio bloqueó el acceso |
| Directorio 755 | La lectura volvió a funcionar |
| umask 077 | Archivo nuevo 600 y directorio nuevo 700 |

La cuenta y el grupo temporales se retiraron al finalizar. Las capturas muestran consultas del registro auténtico de la ejecución. El informe incluye los códigos de salida y la interpretación de cada prueba.

## Ejecución del script

En una terminal de Cloud Shell, desde la carpeta del proyecto:

```bash
bash scripts/practica.sh
```

Ejecutar como usuario normal. El script utiliza sudo para crear identidades locales temporales, registra las pruebas en el directorio personal y retira la cuenta y el grupo al finalizar. Utiliza únicamente datos ficticios y conserva el directorio de prueba para inspección.

## Capturas

Las ocho imágenes originales están en [evidencias/capturas/](evidencias/capturas/). El informe y el PowerPoint también las incluyen para explicar los resultados.

## Bibliografía

El informe identifica los seis documentos de la cátedra y el modelo TPI, complementados con documentación oficial de Google Cloud y los manuales de Linux.

## Repositorio

[https://github.com/gianisgro2-code/TPI-AYSO-Seguridad-Linux](https://github.com/gianisgro2-code/TPI-AYSO-Seguridad-Linux)
