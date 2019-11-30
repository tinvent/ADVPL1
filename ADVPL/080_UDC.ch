#IFDEF SPANISH
   #define STR0001 "Nombre: "
   #define STR0002 "Direccion: "
   #define STR0003 "Telefono: "
#ELSE
   #IFDEF ENGLISH
      #define STR0001 "Name: "
      #define STR0002 "Address: "
      #define STR0003 "Phone: "
   #ELSE
      #define STR0001 "Nome: "
      #define STR0002 "Endereço: "
      #define STR0003 "Telefone: "
   #ENDIF
#ENDIF
