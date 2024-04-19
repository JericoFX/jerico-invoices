# JERICO-BILLS

This one i dont know if is save enought to use it, i create for a server and is no longer online.

- Create Invoice
  - You Can select the amount and the source of the money (cash or bank)
  - A POP UP will appear in the screen of the target id asking for pay the invoice.
    - Player can pay or denied
- Command to check if the player has some bills unpayed. \* You can send again or even edit the source of the money.

      Commands:

      `createInvoice` Will create a new Bill

      `checkInvoice` Will check if the Target ID has some unpayed Bills



   
     SQL Create Table:
   ```sql
      CREATE TABLE IF NOT EXISTS `fx_facturas` (

  `id` int NOT NULL AUTO_INCREMENT,
  `uid` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Bill ID',
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Citizen id del target',
  `monto` int DEFAULT NULL COMMENT 'monto a pagar',
  `retirar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'de donde se va a sacar el dinero',
  `agregado` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'informacion adicional a la factura',
  `enviadopor` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'quien envio la factura',
  `trabajo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'y el trabajo de la persona que envio la factura',
  UNIQUE KEY `id` (`id`) USING BTREE,
  KEY `uid` (`uid`) USING BTREE
  ) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

   ```
