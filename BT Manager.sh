#!/bin/bash

#-------------------------------------#
#          BT Manager 3.6.1           #
#            By djparent              #
#             A fork of               #
#         Bluetooth Manager           #
#           dArkOS Edition            #
#             by Jason                #
#-------------------------------------#

# Copyright (c) 2026 Jason3x
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# -------------------------------------------------------
# Root privileges check
# -------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -E "$0" "$@"
fi

# -------------------------------------------------------
# Variables
# -------------------------------------------------------
SYSTEM_LANG=""
GPTOKEYB_PID=""
CURR_TTY="/dev/tty1"
ARK_UID=$(id -u ark)
TMP_KEYS="/tmp/keys.gptk.$$"
SCRIPT_NAME="$(basename "$0")"
ASOUNDRC="/home/ark/.asoundrc"
ASOUNDRC_BAK="/home/ark/.asoundrcbak"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PULSE_SOCKET="/run/user/${ARK_UID}/pulse/native"
INSTALLED_FLAG="/home/ark/.bt_manager_installed"
ES_CONF="/home/ark/.emulationstation/es_settings.cfg"

# -------------------------------------------------------
# Initialization
# -------------------------------------------------------
export TERM=linux
mkdir -p /run/user/${ARK_UID}
chown ark:ark /run/user/${ARK_UID}
chmod 700 /run/user/${ARK_UID}
export XDG_RUNTIME_DIR=/run/user/${ARK_UID}
export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

if [ -f "$ES_CONF" ]; then
    ES_DETECTED=$(grep "name=\"Language\"" "$ES_CONF" | grep -o 'value="[^"]*"' | cut -d '"' -f 2)
    [ -n "$ES_DETECTED" ] && SYSTEM_LANG="$ES_DETECTED"
fi
# -------------------------------------------------------
# Default configuration : EN
# -------------------------------------------------------
T_BACKTITLE="BT Manager by djparent"
T_STARTING="Starting BT Manager ...\nPlease wait."
T_ERR_TITLE="Error"
T_STOPPING="Stopping Bluetooth..."
T_STARTING_BT="Starting Bluetooth..."
T_ACTION="Action"
T_BT_DISABLED="Bluetooth disabled.\nEnable it first."
T_SCAN_TITLE="Scanning"
T_NO_DEVICE="No named device detected."
T_INFO="Info"
T_NEARBY="Bluetooth nearby"
T_BACK="Back"
T_CHOOSE_DEV="Choose a device:"
T_SUCCESS="Success"
T_CONNECTED="is connected"
T_FAILED="Failed"
T_FAIL_CONNECT="Unable to connect to"
T_FAIL_DISCONNECT="Unable to disconnect"
T_FAIL_MSG="Ensure device is in pairing mode."
T_NO_KNOWN="No known devices."
T_KNOWN_DEV="Known Devices"
T_CONNECT_TO="Connect to:"
T_CONNECTING_TO="Connecting to"
T_NOTHING_DEL="Nothing to delete."
T_DELETE_TITLE="Delete"
T_CHOOSE_DEL="Choose device to forget:"
T_FORGOTTEN="Device forgotten."
T_MAIN_TITLE="Main Menu"
T_QUIT="Quit"
T_STATUS="BT Status"
T_CONN_TO="Connected to"
T_NONE="None"
T_ENABLE="Enable"
T_DISABLE="Disable"
T_M_SCAN="Scan and Connect"
T_M_KNOWN="Known Devices"
T_M_FORGET="Forget a Device"
T_M_QUIT="Quit"
T_FIXING_AUDIO="Fixing audio protocols..."
T_PAIRING="Pairing in progress..."
T_INTERNET="Internet Required"
T_ACTIVE="An active internet connection is required to install components" 
T_UPDATE="Updating package lists..."
T_PACKAGE="Installing" 
T_COMPLETE="Installation complete !"
T_DEPS="Dependencies" 
T_INIT="Initializing..."
T_ON="ON"
T_OFF="OFF"
T_SCAN_INIT="Initializing Bluetooth..."
T_SCAN_PROCESS="Scanning airwaves..."
T_SCAN_RESOLV="Resolving device names..."
T_SCAN_START="Starting scan..."
T_CONN_TITLE="Connection"
T_PROCESS="Processing..."
T_POWERING="Powering on adapter..."
T_SYSTEM_FIX="Applying system fixes..."
T_DEV_DEFAULT="Device"
T_M_DISCONNECT="Disconnect a device"
T_DISCONNECTED="Disconnected"
T_UNKNOWN="Unknown Device"
T_REBOOT_TITLE="Reboot Required"
T_BACKTITLE2="BT Manager Uninstaller"
T_STARTING2="Starting Uninstaller...\nPlease wait."
T_MAIN_TITLE2="Uninstaller Menu"
T_MENU_MSG="\nYour next choice defines your destiny."
T_RUN="Run Uninstaller"
T_EXIT="Exit"
T_STEP1_TITLE="Step 1/7"
T_STEP1_MSG="\nStopping and disabling services..."
T_STEP2_TITLE="Step 2/7"
T_STEP2_MSG="\nRemoving installed files..."
T_STEP3_TITLE="Step 3/7"
T_STEP3_MSG="\nRestoring /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Step 4/7"
T_STEP4_MSG="\nRestoring /etc/pulse/system.pa..."
T_STEP5_TITLE="Step 5/7"
T_STEP5_MSG="\nRestoring bluetooth.service..."
T_STEP6_TITLE="Step 6/7"
T_STEP6_MSG="\nRestoring RetroArch audio driver..."
T_STEP7_TITLE="Step 7/7"
T_STEP7_MSG="\nReloading systemd daemon..."
T_PKG_TITLE="Remove Packages?"
T_PKG_MSG="The installer may have installed:\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nWARNING: May be used by other software.\n\nRemove them now?"
T_REMOVING_TITLE="Removing Packages"
T_REMOVING_MSG="\nRemoving packages..."
T_DONE_TITLE="Uninstall Complete"
T_OPT_MSG="\n - installed packages removed"
T_DONE_MSG="What was undone:\n\n - installed services removed%PKG%\n - device audio drivers restored\n - install flag removed\n\nA reboot is required to restore volume function."
T_REBOOT_TITLE="Reboot?"
T_REBOOT_MSG="\nReboot now to apply all changes?"
T_REBOOTING_TITLE="Rebooting"
T_REBOOTING_MSG="\nRebooting..."
T_FORGET_MENU="Forget All Devices"
T_FORGET_TITLE="Forget All Devices?"
T_FORGET_MSG="\nWould you like to forget all previously\nconnected Bluetooth devices?"
T_FORGETTING_TITLE="Forgetting Devices"
T_FORGETTING_MSG="\nRemoving all paired devices..."
T_FORGOTTEN_TITLE="Done"
T_FORGOTTEN_MSG="\nAll paired devices have been removed."
T_RESCAN="Rescan"

# --- FRANÇAIS (FR) --- 
if [[ "$SYSTEM_LANG" == *"fr"* ]]; then
T_BACKTITLE="BT Manager par djparent"
T_STARTING="Demarrage du BT Manager ...\nVeuillez patienter."
T_ERR_TITLE="Erreur"
T_STOPPING="Arret du Bluetooth..."
T_STARTING_BT="Demarrage du Bluetooth..."
T_ACTION="Action"
T_BT_DISABLED="Bluetooth desactive.\nActivez-le d'abord."
T_SCAN_TITLE="Recherche"
T_NO_DEVICE="Aucun appareil detecte."
T_INFO="Info"
T_NEARBY="Bluetooth a proximite"
T_BACK="Retour"
T_CHOOSE_DEV="Choisissez un appareil :"
T_SUCCESS="Succes"
T_CONNECTED="est connecte"
T_FAILED="Echec"
T_FAIL_CONNECT="Impossible de se connecter a"
T_FAIL_DISCONNECT="Impossible De Se Deconnecter"
T_FAIL_MSG="Verifiez que l'appareil est en mode appairage."
T_NO_KNOWN="Aucun appareil connu."
T_KNOWN_DEV="Appareils connus"
T_CONNECT_TO="Se connecter a :"
T_CONNECTING_TO="Connexion a"
T_NOTHING_DEL="Rien a supprimer."
T_DELETE_TITLE="Supprimer"
T_CHOOSE_DEL="Choisissez l'appareil a oublier :"
T_FORGOTTEN="Appareil oublie."
T_MAIN_TITLE="Menu Principal"
T_QUIT="Quitter"
T_STATUS="Statut BT"
T_CONN_TO="Connecte a"
T_NONE="Aucun"
T_ENABLE="Activer"
T_DISABLE="Desactiver"
T_M_SCAN="Rechercher et Connecter"
T_M_KNOWN="Appareils connus"
T_M_FORGET="Oublier un appareil"
T_M_QUIT="Quitter"
T_FIXING_AUDIO="Reparation des protocoles audio..."
T_PAIRING="Appairage en cours..."
T_INTERNET="Internet requis"
T_ACTIVE="Une connexion internet active est requise pour installer les composants"
T_UPDATE="Mise a jour des listes de paquets..."
T_PACKAGE="Installation"
T_COMPLETE="Installation terminee !"
T_DEPS="Dependances"
T_INIT="Initialisation..."
T_ON="MARCHE"
T_OFF="ARRET"
T_SCAN_INIT="Initialisation Bluetooth..."
T_SCAN_PROCESS="Analyse des ondes radio..."
T_SCAN_RESOLV="Resolution des noms..."
T_SCAN_START="Demarrage du scan..."
T_CONN_TITLE="Connexion"
T_PROCESS="Traitement..."
T_POWERING="Allumage de l'adaptateur..."
T_SYSTEM_FIX="Application des correctifs systeme..."
T_DEV_DEFAULT="Appareil"
T_M_DISCONNECT="Deconnecter un peripherique"
T_DISCONNECTED="Deconnecte"
T_UNKNOWN="Appareil Inconnu"
T_REBOOT_TITLE="Redemarrage requis"
T_BACKTITLE2="Desinstallateur BT Manager"
T_STARTING2="Demarrage du Desinstallateur...\nVeuillez patienter."
T_MAIN_TITLE2="Menu de desinstallation"
T_MENU_MSG="\nVotre prochain choix definit votre destin."
T_RUN="Lancer la Desinstallation"
T_EXIT="Quitter"
T_STEP1_TITLE="Etape 1/7"
T_STEP1_MSG="\nArret et desactivation des services..."
T_STEP2_TITLE="Etape 2/7"
T_STEP2_MSG="\nSuppression des fichiers installes..."
T_STEP3_TITLE="Etape 3/7"
T_STEP3_MSG="\nRestauration de /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Etape 4/7"
T_STEP4_MSG="\nRestauration de /etc/pulse/system.pa..."
T_STEP5_TITLE="Etape 5/7"
T_STEP5_MSG="\nRestauration de bluetooth.service..."
T_STEP6_TITLE="Etape 6/7"
T_STEP6_MSG="\nRestauration du pilote audio RetroArch..."
T_STEP7_TITLE="Etape 7/7"
T_STEP7_MSG="\nRechargement du daemon systemd..."
T_PKG_TITLE="Supprimer les paquets ?"
T_PKG_MSG="L'installateur a peut-etre installe :\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nATTENTION : Peuvent etre utilises par d'autres logiciels.\n\nLes supprimer maintenant ?"
T_REMOVING_TITLE="Suppression des paquets"
T_REMOVING_MSG="\nSuppression des paquets..."
T_DONE_TITLE="Desinstallation terminee"
T_DONE_MSG="Ce qui a ete annule :\n\n - Services installes supprimes%PKG%\n - Pilotes audio restaures\n - Indicateur d'installation supprime\n\nUn redemarrage est requis pour restaurer le volume."
T_REBOOT_TITLE="Redemarrer ?"
T_REBOOT_MSG="\nRedemarrer maintenant pour appliquer les changements ?"
T_REBOOTING_TITLE="Redemarrage"
T_REBOOTING_MSG="\nRedemarrage en cours..."
T_FORGET_MENU="Oublier tous les appareils"
T_FORGET_TITLE="Oublier tous les appareils ?"
T_FORGET_MSG="\nVoulez-vous oublier tous les appareils\nBluetooth precedemment connectes ?"
T_FORGETTING_TITLE="Suppression des appareils"
T_FORGETTING_MSG="\nSuppression de tous les appareils associes..."
T_FORGOTTEN_TITLE="Termine"
T_FORGOTTEN_MSG="\nTous les appareils associes ont ete supprimes."
T_RESCAN="Relancer"

# --- ESPAÑOL (ES) ---
elif [[ "$SYSTEM_LANG" == *"es"* ]]; then
T_BACKTITLE="BT Manager por djparent"
T_STARTING="Iniciando BT Manager ...\nPor favor espere."
T_ERR_TITLE="Error"
T_STOPPING="Deteniendo Bluetooth..."
T_STARTING_BT="Iniciando Bluetooth..."
T_ACTION="Accion"
T_BT_DISABLED="Bluetooth desactivado.\nActivelo primero."
T_SCAN_TITLE="Escaneo"
T_NO_DEVICE="No se detecto ningun dispositivo."
T_INFO="Info"
T_NEARBY="Bluetooth cercano"
T_BACK="Volver"
T_CHOOSE_DEV="Elija un dispositivo:"
T_SUCCESS="Exito"
T_CONNECTED="esta conectado"
T_FAILED="Fallo"
T_FAIL_CONNECT="No se pudo conectar a"
T_FAIL_DISCONNECT="No Se Puede Desconectar"
T_FAIL_MSG="Asegurese de que el dispositivo este en modo emparejamiento."
T_NO_KNOWN="No hay dispositivos conocidos."
T_KNOWN_DEV="Dispositivos conocidos"
T_CONNECT_TO="Conectar a:"
T_CONNECTING_TO="Conectando a"
T_NOTHING_DEL="Nada que eliminar."
T_DELETE_TITLE="Eliminar"
T_CHOOSE_DEL="Elija el dispositivo a olvidar:"
T_FORGOTTEN="Dispositivo olvidado."
T_MAIN_TITLE="Menu Principal"
T_QUIT="Salir"
T_STATUS="Estado de BT"
T_CONN_TO="Conectado a"
T_NONE="Ninguno"
T_ENABLE="Activar"
T_DISABLE="Desactivar"
T_M_SCAN="Escanear y Conectar"
T_M_KNOWN="Dispositivos conocidos"
T_M_FORGET="Olvidar un dispositivo"
T_M_QUIT="Salir"
T_FIXING_AUDIO="Reparando protocolos de audio..."
T_PAIRING="Emparejamiento en curso..."
T_INTERNET="Internet requerido"
T_ACTIVE="Se requiere una conexion a internet activa para instalar componentes"
T_UPDATE="Actualizando listas de paquetes..."
T_PACKAGE="Instalando"
T_COMPLETE="Instalacion completada !"
T_DEPS="Dependencias"
T_INIT="Inicializando..."
T_ON="ENCENDIDO"
T_OFF="APAGADO"
T_SCAN_INIT="Inicializando Bluetooth..."
T_SCAN_PROCESS="Escaneando ondas de radio..."
T_SCAN_RESOLV="Resolviendo nombres..."
T_SCAN_START="Iniciando escaneo..."
T_CONN_TITLE="Conexion"
T_PROCESS="Procesando..."
T_POWERING="Encendiendo adaptador..."
T_SYSTEM_FIX="Aplicando correcciones del sistema..."
T_DEV_DEFAULT="Dispositivo"
T_M_DISCONNECT="Desconectar un dispositivo"
T_DISCONNECTED="Desconectado"
T_UNKNOWN="Dispositivo Desconocido"
T_REBOOT_TITLE="Reinicio requerido"
T_BACKTITLE2="Desinstalador BT Manager"
T_STARTING2="Iniciando Desinstalador...\nPor favor espere."
T_MAIN_TITLE2="Menu de Desinstalacion"
T_MENU_MSG="\nTu proxima eleccion define tu destino."
T_RUN="Ejecutar Desinstalacion"
T_EXIT="Salir"
T_STEP1_TITLE="Paso 1/7"
T_STEP1_MSG="\nDeteniendo y desactivando servicios..."
T_STEP2_TITLE="Paso 2/7"
T_STEP2_MSG="\nEliminando archivos instalados..."
T_STEP3_TITLE="Paso 3/7"
T_STEP3_MSG="\nRestaurando /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Paso 4/7"
T_STEP4_MSG="\nRestaurando /etc/pulse/system.pa..."
T_STEP5_TITLE="Paso 5/7"
T_STEP5_MSG="\nRestaurando bluetooth.service..."
T_STEP6_TITLE="Paso 6/7"
T_STEP6_MSG="\nRestaurando controlador de audio RetroArch..."
T_STEP7_TITLE="Paso 7/7"
T_STEP7_MSG="\nRecargando daemon de systemd..."
T_PKG_TITLE="Eliminar Paquetes ?"
T_PKG_MSG="El instalador puede haber instalado :\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nADVERTENCIA : Pueden ser usados por otro software.\n\nEliminarlos ahora ?"
T_REMOVING_TITLE="Eliminando Paquetes"
T_REMOVING_MSG="\nEliminando paquetes..."
T_DONE_TITLE="Desinstalacion Completa"
T_DONE_MSG="Lo que fue deshecho :\n\n - Servicios instalados eliminados%PKG%\n - Controladores de audio restaurados\n - Indicador de instalacion eliminado\n\nSe requiere reinicio para restaurar el volumen."
T_REBOOT_TITLE="Reiniciar ?"
T_REBOOT_MSG="\nReiniciar ahora para aplicar todos los cambios ?"
T_REBOOTING_TITLE="Reiniciando"
T_REBOOTING_MSG="\nReiniciando..."
T_FORGET_MENU="Olvidar todos los dispositivos"
T_FORGET_TITLE="Olvidar todos los dispositivos ?"
T_FORGET_MSG="\nDesea olvidar todos los dispositivos\nBluetooth conectados anteriormente ?"
T_FORGETTING_TITLE="Olvidando dispositivos"
T_FORGETTING_MSG="\nEliminando todos los dispositivos emparejados..."
T_FORGOTTEN_TITLE="Listo"
T_FORGOTTEN_MSG="\nTodos los dispositivos emparejados han sido eliminados."
T_RESCAN="Reescanear"

# --- PORTUGUÊS (PT) ---
elif [[ "$SYSTEM_LANG" == *"pt"* ]]; then
T_BACKTITLE="BT Manager por djparent"
T_STARTING="Iniciando BT Manager ...\nPor favor aguarde."
T_ERR_TITLE="Erro"
T_STOPPING="Parando Bluetooth..."
T_STARTING_BT="Iniciando Bluetooth..."
T_ACTION="Acao"
T_BT_DISABLED="Bluetooth desativado.\nAtive-o primeiro."
T_SCAN_TITLE="Escaneando"
T_NO_DEVICE="Nenhum dispositivo detectado."
T_INFO="Info"
T_NEARBY="Bluetooth proximo"
T_BACK="Voltar"
T_CHOOSE_DEV="Escolha um dispositivo:"
T_SUCCESS="Sucesso"
T_CONNECTED="esta conectado"
T_FAILED="Falha"
T_FAIL_CONNECT="Nao foi possivel conectar a"
T_FAIL_DISCONNECT="Nao Foi Possivel Desconectar"
T_FAIL_MSG="Certifique-se de que o dispositivo esta em modo de pareamento."
T_NO_KNOWN="Nenhum dispositivo conhecido."
T_KNOWN_DEV="Dispositivos Conhecidos"
T_CONNECT_TO="Conectar a:"
T_CONNECTING_TO="Conectando a"
T_NOTHING_DEL="Nada para deletar."
T_DELETE_TITLE="Deletar"
T_CHOOSE_DEL="Escolha o dispositivo para esquecer:"
T_FORGOTTEN="Dispositivo esquecido."
T_MAIN_TITLE="Menu Principal"
T_QUIT="Sair"
T_STATUS="Status do BT"
T_CONN_TO="Conectado a"
T_NONE="Nenhum"
T_ENABLE="Ativar"
T_DISABLE="Desativar"
T_M_SCAN="Escanear e Conectar"
T_M_KNOWN="Dispositivos Conhecidos"
T_M_FORGET="Esquecer um Dispositivo"
T_M_QUIT="Sair"
T_FIXING_AUDIO="Corrigindo protocolos de audio..."
T_PAIRING="Pareamento em curso..."
T_INTERNET="Internet necessaria"
T_ACTIVE="Uma conexao de internet ativa e necessaria para instalar componentes"
T_UPDATE="Atualizando listas de pacotes..."
T_PACKAGE="Instalando"
T_COMPLETE="Instalacao concluida !"
T_DEPS="Dependencias"
T_INIT="Inicializando..."
T_ON="LIGADO"
T_OFF="DESLIGADO"
T_SCAN_INIT="Inicializando Bluetooth..."
T_SCAN_PROCESS="Digitalizacao de ondas de radio..."
T_SCAN_RESOLV="Resolvendo nomes..."
T_SCAN_START="Iniciando escaneamento..."
T_CONN_TITLE="Conexao"
T_PROCESS="Processando..."
T_POWERING="Ligando adaptador..."
T_SYSTEM_FIX="Aplicando correcoes do sistema..."
T_DEV_DEFAULT="Dispositivo"
T_M_DISCONNECT="Desconectar um dispositivo"
T_DISCONNECTED="Desconectado"
T_UNKNOWN="Dispositivo Desconhecido"
T_REBOOT_TITLE="Reinicio necessario"
T_BACKTITLE2="Desinstalador BT Manager"
T_STARTING2="Iniciando Desinstalador...\nPor favor aguarde."
T_MAIN_TITLE2="Menu de Desinstalacao"
T_MENU_MSG="\nA sua proxima escolha define o seu destino."
T_RUN="Executar Desinstalacao"
T_EXIT="Sair"
T_STEP1_TITLE="Passo 1/7"
T_STEP1_MSG="\nParando e desativando servicos..."
T_STEP2_TITLE="Passo 2/7"
T_STEP2_MSG="\nRemovendo arquivos instalados..."
T_STEP3_TITLE="Passo 3/7"
T_STEP3_MSG="\nRestaurando /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Passo 4/7"
T_STEP4_MSG="\nRestaurando /etc/pulse/system.pa..."
T_STEP5_TITLE="Passo 5/7"
T_STEP5_MSG="\nRestaurando bluetooth.service..."
T_STEP6_TITLE="Passo 6/7"
T_STEP6_MSG="\nRestaurando driver de audio do RetroArch..."
T_STEP7_TITLE="Passo 7/7"
T_STEP7_MSG="\nRecarregando daemon do systemd..."
T_PKG_TITLE="Remover Pacotes ?"
T_PKG_MSG="O instalador pode ter instalado :\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nAVISO : Podem ser usados por outros programas.\n\nRemove-los agora ?"
T_REMOVING_TITLE="Removendo Pacotes"
T_REMOVING_MSG="\nRemovendo pacotes..."
T_DONE_TITLE="Desinstalacao Concluida"
T_DONE_MSG="O que foi desfeito :\n\n - Servicos instalados removidos%PKG%\n - Controladores de audio restaurados\n - Indicador de instalacao removido\n\nE necessario reiniciar para restaurar o volume."
T_REBOOT_TITLE="Reiniciar ?"
T_REBOOT_MSG="\nReiniciar agora para aplicar todas as alteracoes ?"
T_REBOOTING_TITLE="Reiniciando"
T_REBOOTING_MSG="\nReiniciando..."
T_FORGET_MENU="Esquecer todos os dispositivos"
T_FORGET_TITLE="Esquecer todos os dispositivos ?"
T_FORGET_MSG="\nDeseja esquecer todos os dispositivos\nBluetooth anteriormente conectados ?"
T_FORGETTING_TITLE="Esquecendo dispositivos"
T_FORGETTING_MSG="\nRemovendo todos os dispositivos emparelhados..."
T_FORGOTTEN_TITLE="Concluido"
T_FORGOTTEN_MSG="\nTodos os dispositivos emparelhados foram removidos."
T_RESCAN="Reescanear"

# --- ITALIANO (IT) ---
elif [[ "$SYSTEM_LANG" == *"it"* ]]; then
T_BACKTITLE="BT Manager di djparent"
T_STARTING="Avvio di BT Manager ...\nAttendere prego."
T_ERR_TITLE="Errore"
T_STOPPING="Arresto Bluetooth..."
T_STARTING_BT="Avvio Bluetooth..."
T_ACTION="Azione"
T_BT_DISABLED="Bluetooth disattivato.\nAttivarlo prima."
T_SCAN_TITLE="Scansione"
T_NO_DEVICE="Nessun dispositivo rilevato."
T_INFO="Info"
T_NEARBY="Bluetooth vicini"
T_BACK="Indietro"
T_CHOOSE_DEV="Scegli un dispositivo:"
T_SUCCESS="Successo"
T_CONNECTED="e connesso"
T_FAILED="Fallito"
T_FAIL_CONNECT="Impossibile connettersi a"
T_FAIL_DISCONNECT="Impossibile Disconnettersi"
T_FAIL_MSG="Assicurarsi che il dispositivo sia in modalita accoppiamento."
T_NO_KNOWN="Nessun dispositivo noto."
T_KNOWN_DEV="Dispositivi Noti"
T_CONNECT_TO="Connetti a:"
T_CONNECTING_TO="Connessione a"
T_NOTHING_DEL="Nulla da eliminare."
T_DELETE_TITLE="Elimina"
T_CHOOSE_DEL="Scegli dispositivo da dimenticare:"
T_FORGOTTEN="Dispositivo dimenticato."
T_MAIN_TITLE="Menu Principale"
T_QUIT="Esci"
T_STATUS="Stato BT"
T_CONN_TO="Connesso a"
T_NONE="Nessuno"
T_ENABLE="Attiva"
T_DISABLE="Disattiva"
T_M_SCAN="Scansiona e Connetti"
T_M_KNOWN="Dispositivi Noti"
T_M_FORGET="Dimentica un Dispositivo"
T_M_QUIT="Esci"
T_FIXING_AUDIO="Correzione protocolli audio..."
T_PAIRING="Accoppiamento in corso..."
T_INTERNET="Internet richiesto"
T_ACTIVE="E necessaria una connessione internet attiva per installare i componenti"
T_UPDATE="Aggiornamento delle liste dei pacchetti..."
T_PACKAGE="Installazione"
T_COMPLETE="Installazione completata !"
T_DEPS="Dipendenze"
T_INIT="Inizializzazione..."
T_ON="ACCESO"
T_OFF="SPENTO"
T_SCAN_INIT="Inizializzazione Bluetooth..."
T_SCAN_PROCESS="Scansione delle onde radio..."
T_SCAN_RESOLV="Risoluzione nomi..."
T_SCAN_START="Avvio scansione..."
T_CONN_TITLE="Connessione"
T_PROCESS="Elaborazione..."
T_POWERING="Accensione adattatore..."
T_DEV_DEFAULT="Dispositivo"
T_M_DISCONNECT="Disconnettere un dispositivo"
T_DISCONNECTED="Disconnesso"
T_UNKNOWN="Dispositivo Sconosciuto"
T_REBOOT_TITLE="Riavvio richiesto"
T_BACKTITLE2="Disinstallatore BT Manager"
T_STARTING2="Avvio del Disinstallatore...\nAttendere prego."
T_MAIN_TITLE2="Menu di Disinstallazione"
T_MENU_MSG="\nLa tua prossima scelta definisce il tuo destino."
T_RUN="Avvia Disinstallazione"
T_EXIT="Esci"
T_STEP1_TITLE="Passo 1/7"
T_STEP1_MSG="\nArresto e disattivazione dei servizi..."
T_STEP2_TITLE="Passo 2/7"
T_STEP2_MSG="\nRimozione dei file installati..."
T_STEP3_TITLE="Passo 3/7"
T_STEP3_MSG="\nRipristino di /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Passo 4/7"
T_STEP4_MSG="\nRipristino di /etc/pulse/system.pa..."
T_STEP5_TITLE="Passo 5/7"
T_STEP5_MSG="\nRipristino di bluetooth.service..."
T_STEP6_TITLE="Passo 6/7"
T_STEP6_MSG="\nRipristino del driver audio RetroArch..."
T_STEP7_TITLE="Passo 7/7"
T_STEP7_MSG="\nRicaricamento del daemon di systemd..."
T_PKG_TITLE="Rimuovere i Pacchetti ?"
T_PKG_MSG="Il programma di installazione potrebbe aver installato :\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nATTENZIONE : Potrebbero essere usati da altri software.\n\nRimuoverli ora ?"
T_REMOVING_TITLE="Rimozione Pacchetti"
T_REMOVING_MSG="\nRimozione dei pacchetti..."
T_DONE_TITLE="Disinstallazione Completata"
T_DONE_MSG="Cosa e stato annullato :\n\n - Servizi installati rimossi%PKG%\n - Driver audio ripristinati\n - Indicatore di installazione rimosso\n\nE necessario riavviare per ripristinare il volume."
T_REBOOT_TITLE="Riavviare ?"
T_REBOOT_MSG="\nRiavviare ora per applicare tutte le modifiche ?"
T_REBOOTING_TITLE="Riavvio"
T_REBOOTING_MSG="\nRiavvio in corso..."
T_FORGET_MENU="Dimentica tutti i dispositivi"
T_FORGET_TITLE="Dimentica tutti i dispositivi ?"
T_FORGET_MSG="\nVuoi dimenticare tutti i dispositivi\nBluetooth precedentemente connessi ?"
T_FORGETTING_TITLE="Rimozione dispositivi"
T_FORGETTING_MSG="\nRimozione di tutti i dispositivi associati..."
T_FORGOTTEN_TITLE="Fatto"
T_FORGOTTEN_MSG="\nTutti i dispositivi associati sono stati rimossi."
T_RESCAN="Ripeti scansione"

# --- DEUTSCH (DE) ---
elif [[ "$SYSTEM_LANG" == *"de"* ]]; then
T_BACKTITLE="BT Manager von djparent"
T_STARTING="BT Manager wird gestartet ...\nBitte warten."
T_ERR_TITLE="Fehler"
T_STOPPING="Bluetooth wird gestoppt..."
T_STARTING_BT="Bluetooth wird gestartet..."
T_ACTION="Aktion"
T_BT_DISABLED="Bluetooth deaktiviert.\nBitte zuerst aktivieren."
T_SCAN_TITLE="Suche"
T_NO_DEVICE="Kein benanntes Geraet gefunden."
T_INFO="Info"
T_NEARBY="Bluetooth in der Naehe"
T_BACK="Zurueck"
T_CHOOSE_DEV="Geraet auswaehlen:"
T_SUCCESS="Erfolg"
T_CONNECTED="ist verbunden"
T_FAILED="Fehlgeschlagen"
T_FAIL_CONNECT="Verbindung zu fehlgeschlagen"
T_FAIL_DISCONNECT="Verbindung Kann Nicht Getrennt Werden"
T_FAIL_MSG="Stellen Sie sicher, dass das Geraet im Kopplungsmodus ist."
T_NO_KNOWN="Keine bekannten Geraete."
T_KNOWN_DEV="Bekannte Geraete"
T_CONNECT_TO="Verbinden mit:"
T_CONNECTING_TO="Verbindung zu"
T_NOTHING_DEL="Nichts zu loeschen."
T_DELETE_TITLE="Loeschen"
T_CHOOSE_DEL="Geraet zum Vergessen auswaehlen:"
T_FORGOTTEN="Geraet vergessen."
T_MAIN_TITLE="Hauptmenue"
T_QUIT="Beenden"
T_STATUS="BT-Status"
T_CONN_TO="Verbunden mit"
T_NONE="Keine"
T_ENABLE="Aktivieren"
T_DISABLE="Deaktivieren"
T_M_SCAN="Suchen und verbinden"
T_M_KNOWN="Bekannte Geraete"
T_M_FORGET="Geraet vergessen"
T_M_QUIT="Beenden"
T_FIXING_AUDIO="Audioprotokolle werden korrigiert..."
T_PAIRING="Kopplung laeuft..."
T_INTERNET="Internetverbindung erforderlich"
T_ACTIVE="Eine aktive Internetverbindung ist erforderlich, um Komponenten zu installieren"
T_UPDATE="Paketlisten werden aktualisiert..."
T_PACKAGE="Installiere"
T_COMPLETE="Installation abgeschlossen!"
T_DEPS="Abhaengigkeiten"
T_INIT="Initialisierung..."
T_ON="AKTIV"
T_OFF="INAKTIV"
T_SCAN_INIT="Bluetooth wird initialisiert..."
T_SCAN_PROCESS="Funkwellen werden gescannt..."
T_SCAN_RESOLV="Geraetenamen werden aufgeloest..."
T_SCAN_START="Suche wird gestartet..."
T_CONN_TITLE="Verbindung"
T_PROCESS="Verarbeitung..."
T_POWERING="Adapter wird eingeschaltet..."
T_SYSTEM_FIX="Systemkorrekturen werden angewendet..."
T_DEV_DEFAULT="Geraet"
T_M_DISCONNECT="Geraet trennen"
T_DISCONNECTED="Getrennt"
T_UNKNOWN="Unbekanntes Geraet"
T_REBOOT_TITLE="Neustart erforderlich"
T_BACKTITLE2="BT Manager Deinstallation"
T_STARTING2="Deinstallation wird gestartet...\nBitte warten."
T_MAIN_TITLE2="Deinstallationsmenue"
T_MENU_MSG="\nIhre naechste Wahl bestimmt Ihr Schicksal."
T_RUN="Deinstallation starten"
T_EXIT="Beenden"
T_STEP1_TITLE="Schritt 1/7"
T_STEP1_MSG="\nDienste werden gestoppt und deaktiviert..."
T_STEP2_TITLE="Schritt 2/7"
T_STEP2_MSG="\nInstallierte Dateien werden entfernt..."
T_STEP3_TITLE="Schritt 3/7"
T_STEP3_MSG="\n/etc/bluetooth/main.conf wird wiederhergestellt..."
T_STEP4_TITLE="Schritt 4/7"
T_STEP4_MSG="\n/etc/pulse/system.pa wird wiederhergestellt..."
T_STEP5_TITLE="Schritt 5/7"
T_STEP5_MSG="\nbluetooth.service wird wiederhergestellt..."
T_STEP6_TITLE="Schritt 6/7"
T_STEP6_MSG="\nRetroArch-Audiotreiber wird wiederhergestellt..."
T_STEP7_TITLE="Schritt 7/7"
T_STEP7_MSG="\nSystemd-Daemon wird neu geladen..."
T_PKG_TITLE="Pakete entfernen?"
T_PKG_MSG="Der Installer hat moeglicherweise folgendes installiert:\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nWARNUNG: Moeglicherweise von anderer Software genutzt.\n\nJetzt entfernen?"
T_REMOVING_TITLE="Pakete werden entfernt"
T_REMOVING_MSG="\nPakete werden entfernt..."
T_DONE_TITLE="Deinstallation abgeschlossen"
T_DONE_MSG="Was rueckgaengig gemacht wurde:\n\n - installierte Dienste entfernt%PKG%\n - Geraeteaudiotreiber wiederhergestellt\n - Installationskennzeichen entfernt\n\nEin Neustart ist erforderlich, um die Lautstaerkefunktion wiederherzustellen."
T_REBOOT_TITLE="Neu starten?"
T_REBOOT_MSG="\nJetzt neu starten, um alle Aenderungen anzuwenden?"
T_REBOOTING_TITLE="Neustart"
T_REBOOTING_MSG="\nSystem wird neu gestartet..."
T_FORGET_MENU="Alle Geraete vergessen"
T_FORGET_TITLE="Alle Geraete vergessen?"
T_FORGET_MSG="\nMoechten Sie alle zuvor verbundenen\nBluetooth-Geraete vergessen?"
T_FORGETTING_TITLE="Geraete werden vergessen"
T_FORGETTING_MSG="\nAlle gekoppelten Geraete werden entfernt..."
T_FORGOTTEN_TITLE="Fertig"
T_FORGOTTEN_MSG="\nAlle gekoppelten Geraete wurden entfernt."
T_RESCAN="Erneut suchen"

# --- POLSKI (PL) ---
elif [[ "$SYSTEM_LANG" == *"pl"* ]]; then
T_BACKTITLE="BT Manager przez djparent"
T_STARTING="Uruchamianie BT Manager ...\nProsze czekac."
T_ERR_TITLE="Blad"
T_STOPPING="Zatrzymywanie Bluetooth..."
T_STARTING_BT="Uruchamianie Bluetooth..."
T_ACTION="Akcja"
T_BT_DISABLED="Bluetooth wylaczony.\nNajpierw go wlacz."
T_SCAN_TITLE="Skanowanie"
T_NO_DEVICE="Nie wykryto zadnego urzadzenia."
T_INFO="Info"
T_NEARBY="Bluetooth w poblizu"
T_BACK="Wstecz"
T_CHOOSE_DEV="Wybierz urzadzenie:"
T_SUCCESS="Sukces"
T_CONNECTED="jest polaczony"
T_FAILED="Nieudane"
T_FAIL_CONNECT="Nie mozna polaczyc z"
T_FAIL_DISCONNECT="Nie Mozna Rozlaczyc"
T_FAIL_MSG="Upewnij sie, ze urzadzenie jest w trybie parowania."
T_NO_KNOWN="Brak znanych urzadzen."
T_KNOWN_DEV="Znane urzadzenia"
T_CONNECT_TO="Polacz z:"
T_CONNECTING_TO="Laczenie z"
T_NOTHING_DEL="Nic do usuniecia."
T_DELETE_TITLE="Usun"
T_CHOOSE_DEL="Wybierz urzadzenie do zapomnienia:"
T_FORGOTTEN="Urzadzenie zapomniane."
T_MAIN_TITLE="Menu glowne"
T_QUIT="Wyjscie"
T_STATUS="Status BT"
T_CONN_TO="Polaczono z"
T_NONE="Brak"
T_ENABLE="Wlacz"
T_DISABLE="Wylacz"
T_M_SCAN="Skanuj i polacz"
T_M_KNOWN="Znane urzadzenia"
T_M_FORGET="Zapomnij urzadzenie"
T_M_QUIT="Wyjscie"
T_FIXING_AUDIO="Naprawa protokolow audio..."
T_PAIRING="Parowanie w toku..."
T_INTERNET="Internet wymagany"
T_ACTIVE="Aktywne polaczenie internetowe jest wymagane do zainstalowania komponentow"
T_UPDATE="Aktualizowanie list pakietow..."
T_PACKAGE="Instalowanie"
T_COMPLETE="Instalacja zakonczona !"
T_DEPS="Zaleznosci"
T_INIT="Inicjalizowanie..."
T_ON="WLACZONE"
T_OFF="WYLACZONE"
T_SCAN_INIT="Inicjowanie Bluetooth..."
T_SCAN_PROCESS="Skanowanie fal radiowych..."
T_SCAN_RESOLV="Rozpoznawanie nazw..."
T_SCAN_START="Uruchamianie skanowania..."
T_CONN_TITLE="Polaczenie"
T_PROCESS="Przetwarzanie..."
T_POWERING="Wlaczanie adaptera..."
T_SYSTEM_FIX="Stosowanie poprawek systemowych..."
T_DEV_DEFAULT="Urzadzenie"
T_M_DISCONNECT="Rozlaczyc urzadzenie"
T_DISCONNECTED="Rozlaczono"
T_UNKNOWN="Nieznane Urzadzenie"
T_REBOOT_TITLE="Wymagane ponowne uruchomienie"
T_BACKTITLE2="Deinstalator BT Manager"
T_STARTING2="Uruchamianie deinstalatora...\nProsze czekac."
T_MAIN_TITLE2="Menu Deinstalatora"
T_MENU_MSG="\nTwoj nastepny wybor definiuje twoje przeznaczenie."
T_RUN="Uruchom Deinstalator"
T_EXIT="Wyjscie"
T_STEP1_TITLE="Krok 1/7"
T_STEP1_MSG="\nZatrzymywanie i wylaczanie uslug..."
T_STEP2_TITLE="Krok 2/7"
T_STEP2_MSG="\nUsuwanie zainstalowanych plikow..."
T_STEP3_TITLE="Krok 3/7"
T_STEP3_MSG="\nPrzywracanie /etc/bluetooth/main.conf..."
T_STEP4_TITLE="Krok 4/7"
T_STEP4_MSG="\nPrzywracanie /etc/pulse/system.pa..."
T_STEP5_TITLE="Krok 5/7"
T_STEP5_MSG="\nPrzywracanie bluetooth.service..."
T_STEP6_TITLE="Krok 6/7"
T_STEP6_MSG="\nPrzywracanie sterownika audio RetroArch..."
T_STEP7_TITLE="Krok 7/7"
T_STEP7_MSG="\nPrzeladowywanie demona systemd..."
T_PKG_TITLE="Usunac pakiety?"
T_PKG_MSG="Instalator mogl zainstalowac:\n  - bluez\n  - bluez-tools\n  - pulseaudio\n  - pulseaudio-module-bluetooth\n  - dbus-x11\n  - libasound2-plugins\n\nUWAGA: Moga byc uzywane przez inne programy.\n\nUsunac je teraz?"
T_REMOVING_TITLE="Usuwanie pakietow"
T_REMOVING_MSG="\nUsuwanie pakietow..."
T_DONE_TITLE="Deinstalacja zakonczona"
T_DONE_MSG="Co zostalo cofniete:\n\n - zainstalowane uslugi usuniete%PKG%\n - sterowniki audio urzadzenia przywrocone\n - flaga instalacji usunieta\n\nWymagane ponowne uruchomienie aby przywrocic funkcje glosnosci."
T_REBOOT_TITLE="Uruchomic ponownie?"
T_REBOOT_MSG="\nUruchomic ponownie aby zastosowac wszystkie zmiany?"
T_REBOOTING_TITLE="Ponowne uruchamianie"
T_REBOOTING_MSG="\nPonowne uruchamianie..."
T_FORGET_MENU="Zapomnij wszystkie urzadzenia"
T_FORGET_TITLE="Zapomniec wszystkie urzadzenia?"
T_FORGET_MSG="\nCzy chcesz zapomniec wszystkie poprzednio\npolaczone urzadzenia Bluetooth?"
T_FORGETTING_TITLE="Zapominanie urzadzen"
T_FORGETTING_MSG="\nUsuwanie wszystkich sparowanych urzadzen..."
T_FORGOTTEN_TITLE="Gotowe"
T_FORGOTTEN_MSG="\nWszystkie sparowane urzadzenia zostaly usuniete."
T_RESCAN="Skanuj ponownie"
fi

# -------------------------------------------------------
# Start gamepad input
# -------------------------------------------------------
StartGPTKeyb() {
    pkill -9 -f gptokeyb 2>/dev/null || true
    if [ -n "${GPTOKEYB_PID:-}" ]; then
        kill "$GPTOKEYB_PID" 2>/dev/null
    fi
    sleep 0.1
	/opt/inttools/gptokeyb -1 "$0" -c "$TMP_KEYS" > /dev/null 2>&1 &
    GPTOKEYB_PID=$!
}

# -------------------------------------------------------
# Stop gamepad input
# -------------------------------------------------------
StopGPTKeyb() {
    if [ -n "$GPTOKEYB_PID" ]; then
        kill "$GPTOKEYB_PID" 2>/dev/null
        GPTOKEYB_PID=""
    fi
}

Cleanup() {
    rm -f "$TMP_KEYS"
}

# -------------------------------------------------------
# Font Selection
# -------------------------------------------------------
ORIGINAL_FONT=$(setfont -v 2>&1 | grep -o '/.*\.psf.*')
setfont /usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz

# -------------------------------------------------------
# Display Management
# -------------------------------------------------------
printf "\e[?25l" > "$CURR_TTY"
dialog --clear
StopGPTKeyb
pgrep -f osk.py | xargs kill -9
printf "\033[H\033[2J" > "$CURR_TTY"
printf "$T_STARTING" > "$CURR_TTY"
sleep 0.1

# -------------------------------------------------------
# Bluetooth Status
# -------------------------------------------------------
GetPowerStatus() {
    if rfkill list bluetooth | grep -q "Soft blocked: yes"; then return 1; fi
    if ! systemctl is-active --quiet bluetooth; then return 1; fi
    if ! echo "show" | bluetoothctl | sed 's/\x1b\[[0-9;]*m//g' | grep -q "Powered: yes"; then return 1; fi
    return 0
}

# -------------------------------------------------------
# Get Name of Connected Device
# -------------------------------------------------------
GetConnectedName() {
    local found_name=""
    found_name=$(timeout 3 bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
        if timeout 2 bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            echo "$name"
            break
        fi
    done)
    echo "${found_name:-$T_NONE}"
}

# -------------------------------------------------------
# Route ALSA through PulseAudio (for BT audio)
# -------------------------------------------------------
SetAsoundPulse() {
    cat <<ASOUND > "$ASOUNDRC"
pcm.!default {
    type pulse
    server unix:$PULSE_SOCKET
}
ctl.!default {
    type pulse
    server unix:$PULSE_SOCKET
}
ASOUND
    chown ark:ark "$ASOUNDRC"
}

# -------------------------------------------------------
# Restore ALSA direct routing (for internal speaker)
# -------------------------------------------------------
SetAsoundDirect() {
    if [ -f "$ASOUNDRC_BAK" ] && [ -s "$ASOUNDRC_BAK" ]; then
        cp "$ASOUNDRC_BAK" "$ASOUNDRC"
    else
        cat <<ASOUND > "$ASOUNDRC"
pcm.!default {
    type plug
    slave.pcm "dmixer"
}
pcm.dmixer {
    type dmix
    ipc_key 1024
    slave {
        pcm "hw:0,0"
        period_time 0
        period_size 1024
        buffer_size 4096
        rate 44100
    }
    bindings {
        0 0
        1 1
    }
}
ctl.!default { type hw card 0 }
ASOUND
    fi
    chown ark:ark "$ASOUNDRC"
}

# -------------------------------------------------------
# Exit the script
# -------------------------------------------------------
ExitMenu() {
	trap - EXIT
    printf "\033[H\033[2J" > "$CURR_TTY"
    printf "\e[?25h" > "$CURR_TTY"
    StopGPTKeyb
    if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
        [ -n "$ORIGINAL_FONT" ] && setfont "$ORIGINAL_FONT"
    fi

    exit 0
}

# -------------------------------------------------------
# Dependency Check
# -------------------------------------------------------
CheckDeps() {
    [ -f "$INSTALLED_FLAG" ] && return
    
    local REQUIRED_PACKAGES=("bluez" "pulseaudio-module-bluetooth" "pulseaudio" "alsa-utils" "evtest" "libasound2-plugins" "dbus-user-session" "dbus-x11" "bluez-tools")
    local MISSING_PACKAGES=()
    
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then MISSING_PACKAGES+=("$pkg"); fi
    done

    if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
        if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
            dialog --backtitle "$T_BACKTITLE" --title "$T_INTERNET" --msgbox "\n$T_ACTIVE:\n\n${MISSING_PACKAGES[*]}" 8 50 > "$CURR_TTY"
            ExitMenu
        fi

        (
            current_p=0

			# --- Function to advance the bar while a command is being processed ---
            progress_while_running() {
                local pid=$1
                local target=$2
                local msg=$3

                while kill -0 $pid 2>/dev/null; do
                    if [ $current_p -lt $target ]; then
                        current_p=$((current_p + 1))
                        echo "$current_p"
                        echo "XXX"; echo "$msg"; echo "XXX"
                    fi
                    sleep 0.15 
                done

                current_p=$target
                echo "$current_p"
                echo "XXX"; echo "$msg"; echo "XXX"
            }

            # --- Updating Repositories ---
            apt-get update -y >/dev/null 2>&1 &
            progress_while_running $! 25 "$T_UPDATE"

            # --- Installing Packages ---
            TOTAL=${#MISSING_PACKAGES[@]}
            COUNT=0
            for pkg in "${MISSING_PACKAGES[@]}"; do
                COUNT=$((COUNT + 1))
               
                start_section=$(( 25 + ( (COUNT - 1) * 70 / TOTAL ) ))
                end_section=$(( 25 + ( COUNT * 70 / TOTAL ) ))
                
                DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" >/dev/null 2>&1 &
                progress_while_running $! $end_section "$T_PACKAGE $pkg ($COUNT/$TOTAL)..."
            done

            # --- Finalization ---
            while [ $current_p -lt 100 ]; do
                current_p=$((current_p + 1))
                echo "$current_p"
                echo "XXX"; echo "$T_COMPLETE"; echo "XXX"
                sleep 0.05
            done
            
        ) | dialog --backtitle "$T_BACKTITLE" --title "$T_DEPS" --gauge "\n$T_INIT" 8 50 0 > "$CURR_TTY"
    fi
}

# -------------------------------------------------------
# Volume Configuration
# -------------------------------------------------------
FixVolumeScript() {
    cat <<EOF | sudo tee /usr/local/bin/bt-volume-monitor.sh > /dev/null
#!/bin/bash
PA="pactl --server=unix:$PULSE_SOCKET"

until [ -S $PULSE_SOCKET ]; do
    sleep 1
done

EV="/dev/input/event3"
[ ! -e "\$EV" ] && EV="/dev/input/\$(grep -E 'Handlers|Name' /proc/bus/input/devices | grep -A1 "odroidgo3-keys" | grep -oE 'event[0-9]+' | head -n1)"

CUR_VOL=60
BT_SINK=""

refresh_sink() {
    BT_SINK=\$(\$PA list short sinks 2>/dev/null | grep bluez_sink | awk '{print \$2}')
}

sync_vol() {
    [ -z "\$BT_SINK" ] && return
    local V=\$(\$PA list sinks 2>/dev/null | awk "/Name: \$BT_SINK/{found=1} found && /Volume:/ && !/Base/{match(\\\$0,/[0-9]+%/); print substr(\\\$0,RSTART,RLENGTH-1); exit}")
    [ -n "\$V" ] && CUR_VOL=\$V
}

setvol() {
    local DIR=\$1
    [ -z "\$BT_SINK" ] && return
    CUR_VOL=\$(( DIR > 0 ? CUR_VOL + 2 : CUR_VOL - 2 ))
    [ "\$CUR_VOL" -gt 100 ] && CUR_VOL=100
    [ "\$CUR_VOL" -lt 0 ] && CUR_VOL=0
    \$PA set-sink-volume "\$BT_SINK" \${CUR_VOL}% >/dev/null 2>&1
    if [ "\$CUR_VOL" -eq 0 ]; then
        \$PA set-sink-mute "\$BT_SINK" 1 >/dev/null 2>&1
    else
        \$PA set-sink-mute "\$BT_SINK" 0 >/dev/null 2>&1
    fi
}

refresh_sink
sync_vol

while read line; do
    if [[ "\$line" == *"KEY_VOLUMEUP"* && "\$line" == *"value 1"* ]]; then
        refresh_sink; setvol 1
    elif [[ "\$line" == *"KEY_VOLUMEUP"* && "\$line" == *"value 2"* ]]; then
        setvol 1
    elif [[ "\$line" == *"KEY_VOLUMEDOWN"* && "\$line" == *"value 1"* ]]; then
        refresh_sink; setvol -1
    elif [[ "\$line" == *"KEY_VOLUMEDOWN"* && "\$line" == *"value 2"* ]]; then
        setvol -1
    fi
done < <(stdbuf -oL evtest "\$EV" 2>/dev/null)
EOF
    sudo chmod +x /usr/local/bin/bt-volume-monitor.sh
}

# -------------------------------------------------------
# Configure Bluetooth
# -------------------------------------------------------
FixBluetoothConfig() {
    dialog --backtitle "$T_BACKTITLE" --title "$T_INFO" --infobox "\n$T_SYSTEM_FIX" 5 50 > "$CURR_TTY"

    REAL_BT_PATH=$(find /usr -name bluetoothd -type f -executable | head -n 1)
    
    if [ -n "$REAL_BT_PATH" ]; then
        sudo sed -i "s|^ExecStart=.*|ExecStart=$REAL_BT_PATH --noplugin=sap|" /lib/systemd/system/bluetooth.service
    fi

    # Groups and Permissions
    for u in ark root pulse; do
        sudo usermod -aG pulse-access,audio,bluetooth,input $u 2>/dev/null
    done

    # Config PulseAudio
    cat <<EOF | sudo tee /etc/pulse/default.pa > /dev/null
load-module module-device-restore
load-module module-stream-restore
load-module module-card-restore
load-module module-augment-properties
load-module module-udev-detect
load-module module-native-protocol-unix auth-anonymous=1 socket=${PULSE_SOCKET}
load-module module-rescue-streams
load-module module-always-sink
load-module module-intended-roles
load-module module-suspend-on-idle
load-module module-switch-on-connect
EOF
	
	# --- DarkOS needs explicit ALSA sink — udev-detect doesn't create one ---
    if [ "${ARK_UID}" = "1000" ]; then
        sudo sed -i '/load-module module-udev-detect/i load-module module-alsa-sink device=default sink_name=internal_speaker' /etc/pulse/default.pa
    fi
	
    # --- Prevent double-loading of modules — system.pa would conflict with default.pa ---
    sudo truncate -s 0 /etc/pulse/system.pa
	
    cat <<EOF | sudo tee /etc/pulse/daemon.conf > /dev/null
flat-volumes = no
deferred-volume-safety-margin-usec = 1
EOF

    # --- Activate Autospawn ---
    grep -q "autospawn = yes" /etc/pulse/client.conf 2>/dev/null || echo "autospawn = yes" | sudo tee -a /etc/pulse/client.conf > /dev/null

    # --- PulseAudio Service ---
    cat <<EOF | sudo tee /etc/systemd/system/pulseaudio.service > /dev/null
[Unit]
Description=PulseAudio Sound Daemon
After=bluetooth.service alsa-restore.service
Before=emulationstation.service

[Service]
Type=simple
User=ark
Environment=PULSE_RUNTIME_PATH=/run/user/${ARK_UID}/pulse
ExecStartPre=/bin/mkdir -p /run/user/${ARK_UID}/pulse
ExecStartPre=/bin/chown ark:ark /run/user/${ARK_UID}/pulse
ExecStartPre=-/bin/rm -f /run/user/${ARK_UID}/pulse/pid
ExecStartPre=-/bin/rm -f $PULSE_SOCKET
ExecStart=/usr/bin/pulseaudio --daemonize=no --exit-idle-time=-1 --no-cpu-limit --disable-shm=false
Restart=always
RestartSec=2
StartLimitIntervalSec=0

[Install]
WantedBy=multi-user.target
EOF

    # --- Service Volume — runs as ark, event3 made accessible via udev rule ---
    cat <<EOF | sudo tee /etc/systemd/system/bt-volume-monitor.service > /dev/null
[Unit]
Description=R36S Volume Buttons Monitor
After=pulseaudio.service

[Service]
Type=simple
ExecStart=/usr/local/bin/bt-volume-monitor.sh
Restart=always
RestartSec=2
User=ark
Nice=-15

[Install]
WantedBy=multi-user.target
EOF

    # --- udev rule to make event3 accessible to ark ---
    echo 'KERNEL=="event3", SUBSYSTEM=="input", MODE="0666"' | sudo tee /etc/udev/rules.d/99-input-event3.rules > /dev/null
    sudo udevadm control --reload-rules

    # --- Service bt-sink-switch ---
    cat <<EOF | sudo tee /etc/systemd/system/bt-sink-switch.service > /dev/null
[Unit]
Description=Bluetooth Audio Sink Auto-Switch
After=pulseaudio.service bluetooth.service
After=sound.target

[Service]
Type=simple
User=ark
Environment=PULSE_RUNTIME_PATH=/run/user/${ARK_UID}/pulse
ExecStart=/usr/local/bin/bt-sink-switch.sh
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# --- detect internal sink name ---
sleep 2
INTERNAL_SINK_NAME=$(pactl --server=unix:${PULSE_SOCKET} list short sinks 2>/dev/null | \
	grep -v bluez | grep -v auto_null | awk '{print $2}' | head -n1)
[ -z "$INTERNAL_SINK_NAME" ] && INTERNAL_SINK_NAME="internal_speaker"

    cat <<EOF | sudo tee /usr/local/bin/bt-sink-switch.sh > /dev/null
#!/bin/bash
PA="pactl --server=unix:$PULSE_SOCKET"

until [ -S $PULSE_SOCKET ] && \$PA info >/dev/null 2>&1; do
    sleep 1
done

LAST_STATE=""
declare -A LAST_SEEN
DEBOUNCE_SEC=5

(
    bluetoothctl --monitor |
    while read -r line; do
        case "\$line" in
				*"[NEW] Device "*|*"[CHG] Device "*)
                mac=\$(echo "\$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
                [ -z "\$mac" ] && continue
				
				now=\$(date +%s)
				if [[ -n "\${LAST_SEEN[\$mac]}" ]]; then
					diff=\$((now - LAST_SEEN[\$mac]))
					[ "\$diff" -lt "\$DEBOUNCE_SEC" ] && continue
				fi
				LAST_SEEN[\$mac]=\$now

                info=\$(bluetoothctl info "\$mac")
				
				connected=\$(echo "\$info" | awk -F': ' '/Connected/ {print \$2}')
				paired=\$(echo "\$info" | awk -F': ' '/Paired/ {print \$2}')

				[ "\$paired" != "yes" ] && continue
				[ "\$connected" != "no" ] && continue

                sleep 1
                bluetoothctl connect "\$mac" >/dev/null 2>&1 &
            ;;
        esac
    done
) &

while true; do
    CONNECTED=\$(timeout 2 bluetoothctl info 2>/dev/null | grep -c "Connected: yes")
    if [ "\$CONNECTED" -gt 0 ] && [ "\$LAST_STATE" != "connected" ]; then
        ICON=\$(bluetoothctl info 2>/dev/null | grep "Icon:" | awk '{print \$2}')
        [[ "\$ICON" != audio* ]] && continue
        LAST_STATE="connected"
        sleep 1
        CARD=\$(\$PA list short cards 2>/dev/null | grep bluez_card | awk '{print \$2}')
        [ -n "\$CARD" ] && \$PA set-card-profile "\$CARD" a2dp_sink 2>/dev/null
        sleep 1
        BT_SINK=\$(\$PA list short sinks 2>/dev/null | grep bluez_sink | awk '{print \$2}')
        [ -n "\$BT_SINK" ] && \$PA set-default-sink "\$BT_SINK" 2>/dev/null
        for stream in \$(\$PA list short sink-inputs 2>/dev/null | awk '{print \$1}'); do
            \$PA move-sink-input "\$stream" "\$BT_SINK" 2>/dev/null
        done
    elif [ "\$CONNECTED" -eq 0 ] && [ "\$LAST_STATE" != "disconnected" ]; then
        LAST_STATE="disconnected"
        \$PA suspend ${INTERNAL_SINK_NAME} 0 2>/dev/null
        sleep 0.5
        \$PA set-default-sink ${INTERNAL_SINK_NAME} 2>/dev/null
        \$PA set-sink-mute ${INTERNAL_SINK_NAME} 0 2>/dev/null
        \$PA set-sink-volume ${INTERNAL_SINK_NAME} 65% 2>/dev/null
        for stream in \$(\$PA list short sink-inputs 2>/dev/null | awk '{print \$1}'); do
            \$PA move-sink-input "\$stream" ${INTERNAL_SINK_NAME} 2>/dev/null
        done
        /usr/local/bin/reset-alsa.sh
    fi
    sleep 2
done
EOF
    sudo chmod +x /usr/local/bin/bt-sink-switch.sh

    # --- Setting up Bluetooth ---
    sudo chmod 755 /etc/bluetooth
    cat <<EOF | sudo tee /etc/bluetooth/main.conf > /dev/null
[General]
JustWorksRepairing = always
AutoEnable = false
FastConnectable = true
Experimental = true
ReconnectAttempts = 7
ReconnectInterval = 5
EOF

# --- RetroArch and RetroArch32 Audio Setup ---
    local RA_CONFIGS=("/home/ark/.config/retroarch/retroarch.cfg" "/home/ark/.config/retroarch32/retroarch.cfg")
    
    for conf in "${RA_CONFIGS[@]}"; do
        if [ -f "$conf" ]; then
            if grep -q "^audio_driver =" "$conf"; then
                sudo sed -i 's/^audio_driver = .*/audio_driver = "sdl2"/' "$conf"
            else
        echo 'audio_driver = "sdl2"' | sudo tee -a "$conf" > /dev/null
            fi
        fi
    done
    
    FixVolumeScript

	grep -q "PULSE_SERVER" /etc/environment 2>/dev/null || \
		echo "PULSE_SERVER=unix:${PULSE_SOCKET}" >> /etc/environment
	grep -q "XDG_RUNTIME_DIR" /etc/environment 2>/dev/null || \
		echo "XDG_RUNTIME_DIR=/run/user/${ARK_UID}" >> /etc/environment
	
    sudo systemctl daemon-reload
    sudo systemctl unmask bluetooth.service 2>/dev/null
    sudo systemctl enable bluetooth.service
    sudo systemctl enable pulseaudio.service
    sudo systemctl enable bt-volume-monitor.service
    sudo systemctl enable bt-sink-switch.service
    
    # --- Immediate restart to test ---
    sudo systemctl restart bluetooth.service
    sudo systemctl restart pulseaudio.service
    sudo systemctl restart bt-volume-monitor.service
    sudo systemctl restart bt-sink-switch.service
	
	# Only load explicit ALSA sink if udev-detect didn't create one
    sleep 2
    if ! pactl --server=unix:${PULSE_SOCKET} list short sinks 2>/dev/null | grep -q "alsa_output"; then
        pactl --server=unix:${PULSE_SOCKET} load-module module-alsa-sink device=default sink_name=internal_speaker >/dev/null 2>&1
    fi
	
# --- Default to ALSA sink at boot ---
	# --- Create reset-alsa.service ---
	sudo tee /etc/systemd/system/reset-alsa.service > /dev/null <<'EOF'
[Unit]
Description=Force internal ALSA audio at boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/reset-alsa.sh
RemainAfterExit=yes
User=ark

[Install]
WantedBy=multi-user.target
EOF

	# --- Create reset-alsa.sh ---
	sudo tee /usr/local/bin/reset-alsa.sh > /dev/null <<'EOF'
#!/bin/bash

ASOUNDRC="/home/ark/.asoundrc"
ASOUNDRC_BAK="/home/ark/.asoundrcbak"

# Restore .asoundrc to direct ALSA
if [ -f "$ASOUNDRC_BAK" ] && [ -s "$ASOUNDRC_BAK" ]; then
    cp "$ASOUNDRC_BAK" "$ASOUNDRC"
else
    cat <<ASOUND > "$ASOUNDRC"
pcm.!default {
    type plug
    slave.pcm "dmixer"
}
pcm.dmixer {
    type dmix
    ipc_key 1024
    slave {
        pcm "hw:0,0"
        period_time 0
        period_size 1024
        buffer_size 4096
        rate 44100
    }
    bindings {
        0 0
        1 1
    }
}
ctl.!default { type hw card 0 }
ASOUND
fi
chown ark:ark "$ASOUNDRC"
EOF

sudo chmod +x /usr/local/bin/reset-alsa.sh

# --- Enable the service ---
sudo systemctl daemon-reload
sudo systemctl enable reset-alsa.service
}

# -------------------------------------------------------
# First run check for installed_flag
# -------------------------------------------------------
EnsurePermissions() {
    if [ ! -f "$INSTALLED_FLAG" ]; then
        FixBluetoothConfig
        touch "$INSTALLED_FLAG"
        if dialog --backtitle "$T_BACKTITLE" --title "$T_REBOOT_TITLE" --yesno "$T_REBOOT_MSG" 6 50 > "$CURR_TTY"; then
            reboot
        fi
    fi
}

# -------------------------------------------------------
# Find internal audio sink
# -------------------------------------------------------
GetInternalSink() {
    local sink
    sink=$(pactl --server=unix:${PULSE_SOCKET} list short sinks 2>/dev/null | grep -v bluez | grep -v auto_null | awk '{print $2}' | head -n1)
    echo "${sink:-internal_speaker}"
}

# -------------------------------------------------------
# Set Runtime,Start PulseAudio with Server Check
# -------------------------------------------------------
CheckPulse() {
	export XDG_RUNTIME_DIR=/run/user/${ARK_UID}
	export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native
	export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

	if ! sudo -u ark XDG_RUNTIME_DIR=/run/user/${ARK_UID} pactl info >/dev/null 2>&1; then
        sudo -u ark XDG_RUNTIME_DIR=/run/user/${ARK_UID} pulseaudio --start
	fi
	
	sleep 0.1
	
    local PA_CMD="pactl --server=unix:$PULSE_SOCKET"
    $PA_CMD list short modules 2>/dev/null | grep -q module-bluetooth-policy || \
        $PA_CMD load-module module-bluetooth-policy > /dev/null 2>&1
    $PA_CMD list short modules 2>/dev/null | grep -q module-bluetooth-discover || \
        $PA_CMD load-module module-bluetooth-discover > /dev/null 2>&1
}

# -------------------------------------------------------
# Audio patch
# -------------------------------------------------------
ApplyAudioFix() {
	local PA_CMD="pactl --server=unix:$PULSE_SOCKET"
    
	# --- Only wait for bluez_card if a device is actually connected ---
    local CARD=""
    local attempts=0
    while [ -z "$CARD" ] && [ $attempts -lt 5 ]; do
        sleep 0.5
        CARD=$($PA_CMD list short cards 2>/dev/null | grep "bluez_card" | awk '{print $2}')
		attempts=$((attempts + 1))
    done
	[ -n "$CARD" ] && $PA_CMD set-card-profile "$CARD" a2dp_sink >/dev/null 2>&1
	
    local BT_SINK=$($PA_CMD list short sinks 2>/dev/null | grep "bluez_sink" | awk '{print $2}')
	
    if [ -n "$BT_SINK" ]; then
        $PA_CMD set-default-sink "$BT_SINK" >/dev/null 2>&1

        local CARD=$($PA_CMD list short cards 2>/dev/null | grep "bluez_card" | awk '{print $2}')
        if [ -n "$CARD" ]; then
            $PA_CMD set-card-profile "$CARD" a2dp_sink >/dev/null 2>&1
        fi

        $PA_CMD set-sink-volume "$BT_SINK" 60% >/dev/null 2>&1

		# Route ALSA through PulseAudio so SDL2/RetroArch audio goes to BT
        SetAsoundPulse
    else
		$PA_CMD set-default-sink $(GetInternalSink) >/dev/null 2>&1
        $PA_CMD set-sink-mute $(GetInternalSink) 0 >/dev/null 2>&1
        SetAsoundDirect
    fi

    # -- Move all current audio streams to the new output ---
    local DEFAULT_SINK=$($PA_CMD info 2>/dev/null | grep "Default Sink" | awk '{print $3}')
	for stream in $($PA_CMD list short sink-inputs 2>/dev/null | awk '{print $1}'); do
        $PA_CMD move-sink-input "$stream" "$DEFAULT_SINK" >/dev/null 2>&1
    done
}

# -------------------------------------------------------
# Route Audio Through Speakers
# -------------------------------------------------------
ForceInternalAudio() {
    local PA_CMD="pactl --server=unix:$PULSE_SOCKET"

    $PA_CMD set-default-sink $(GetInternalSink) >/dev/null 2>&1
    $PA_CMD set-sink-mute $(GetInternalSink) 0 >/dev/null 2>&1
    $PA_CMD set-sink-volume $(GetInternalSink) 65% >/dev/null 2>&1

    # --- Restore ALSA direct routing ---
    SetAsoundDirect

    # --- The current audio is being moved to the speaker ---
    for stream in $($PA_CMD list short sink-inputs 2>/dev/null | awk '{print $1}'); do
        $PA_CMD move-sink-input "$stream" $(GetInternalSink) >/dev/null 2>&1
    done
}

# -------------------------------------------------------
# Enable Bluetooth
# -------------------------------------------------------
EnableBT() {
	rfkill unblock bluetooth > /dev/null 2>&1
	systemctl start bluetooth > /dev/null 2>&1 &
	bluetoothctl power on > /dev/null 2>&1
	
	(
	CheckPulse
	sleep 1
	bluetoothctl devices | awk '{print $2}' | while read -r mac; do
		if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
			bluetoothctl connect "$mac" >/dev/null 2>&1 &
			sleep 2
			
			if ! bluetoothctl info "$mac" | grep -q "Connected: yes"; then
				bluetoothctl connect "$mac" >/dev/null 2>&1 &
			fi
		fi
	done
	sleep 2
	ApplyAudioFix
	) &
}

# -------------------------------------------------------
# Toggle Bluetooth
# -------------------------------------------------------
ToggleBT() {
	if GetPowerStatus; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_ACTION" --infobox "\n  $T_STOPPING" 5 35 > "$CURR_TTY"
		bluetoothctl power off > /dev/null 2>&1
		systemctl stop bluetooth > /dev/null 2>&1
		ForceInternalAudio
	else
		dialog --backtitle "$T_BACKTITLE" --title "$T_ACTION" --infobox "\n  $T_POWERING" 5 35 > "$CURR_TTY"
		EnableBT
	fi         
}

# -------------------------------------------------------
# Auto-enable Bluetooth if not already on
# -------------------------------------------------------
AutoEnableBT() {
	if ! GetPowerStatus; then
		EnableBT
	fi
 }
 
# -------------------------------------------------------
# Scan and Connect
# -------------------------------------------------------
ScanAndConnect() {
	(
	AutoEnableBT
	) &
	if ! GetPowerStatus; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_ERR_TITLE" --msgbox "\n $T_BT_DISABLED" 8 30 > "$CURR_TTY"
		return
	fi
  
	rm -f /tmp/bt_scan_results.txt
 
	(
    echo "0"; echo "XXX"; echo "$T_POWERING"; echo "XXX"
    bluetoothctl power on > /dev/null 2>&1
    bluetoothctl agent on > /dev/null 2>&1
    bluetoothctl default-agent > /dev/null 2>&1
    bluetoothctl pairable on > /dev/null 2>&1
    bluetoothctl discoverable on > /dev/null 2>&1
    
    SCAN_TIME=8
    bluetoothctl --timeout $SCAN_TIME scan on > /tmp/bt_scan_results.txt 2>&1 &
    SCAN_PID=$!
    
    for ((i=0; i<=SCAN_TIME*10; i++)); do
        PERCENT=$(( i * 100 / (SCAN_TIME * 10) ))
        if [ $i -lt 30 ]; then MSG="$T_SCAN_INIT"; 
        elif [ $i -lt 80 ]; then MSG="$T_SCAN_PROCESS"; 
        else MSG="$T_SCAN_RESOLV"; fi
        
        echo "$PERCENT"
        echo "XXX"; echo "$MSG"; echo "XXX"
        sleep 0.1
    done
    wait $SCAN_PID
    bluetoothctl scan off > /dev/null 2>&1
    echo "100"
	) | dialog --backtitle "$T_BACKTITLE" --title "$T_SCAN_TITLE" --gauge "$T_SCAN_START" 6 45 0 > "$CURR_TTY"

	bluetoothctl devices > /tmp/bt_devices_list.txt
	unset coptions
	while read -r line; do
		if [[ "$line" == *"Device"* ]]; then
			# --- Clean extraction of MAC and Name ---
			local mac=$(echo "$line" | awk '{print $2}')
			
			# Skip already paired devices
			if bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
				continue
			fi
			
			local name=$(echo "$line" | cut -d ' ' -f 3-)
        
		# --- Cleaning of spaces ---
		name=$(echo "$name" | xargs)

		# --- Filters ---
		local valid=true
        
        # No Name Displayed
        if [ -z "$name" ] || [ "$name" == "$line" ]; then name="$T_UNKNOWN"; fi
        # The Name is the same as MAC
        if [[ "$name" =~ ^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$ ]]; then valid=false; fi
		# Drop devices where the name IS the MAC (hyphen format: 39-3B-7C-6E-C1-47)
		if [[ "$name" =~ ^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$ ]]; then valid=false; fi
        # Filtre de messages d'erreur système
        if [[ "$name" == *"rguments"* ]] || [[ "$name" == *"not available"* ]]; then valid=false; fi
		
        if [ "$valid" = true ]; then
			local display_name="$name"
            # # On verifie si dejà connecte (Check if already connected)
            # if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
                # display_name="\Z5* $name $T_CONNECTED *\Zn"
            # fi
            coptions+=("$mac" "$display_name")
        fi
    fi
	done < /tmp/bt_devices_list.txt

	if [ ${#coptions[@]} -eq 0 ]; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_INFO" --msgbox "\n $T_NO_DEVICE" 8 40 > "$CURR_TTY"
		return
	fi

	while true; do
    cselection=$(dialog --colors --backtitle "$T_BACKTITLE" --title "$T_NEARBY" \
        --cancel-label "$T_BACK" \
        --extra-button --extra-label "$T_RESCAN" \
        --menu "$T_CHOOSE_DEV" 15 50 8 "${coptions[@]}" 2>&1 > "$CURR_TTY")
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        ConnectProcess "$cselection"
        return
    elif [ $exit_code -eq 3 ]; then
        ScanAndConnect
        return
    else
        return
    fi
	done
}

# -------------------------------------------------------
# Wait for Stable Connection
# -------------------------------------------------------
is_connected_stable() {
    local mac="$1"
    local PA_CMD="pactl --server=unix:$PULSE_SOCKET"

    sleep 0.5

    if bluetoothctl info "$mac" | sed 's/\x1b\[[0-9;]*m//g' | grep -q "Connected: yes"; then
        return 0
    fi

    if $PA_CMD list short sinks | grep -q "bluez_sink"; then
        return 0
    fi
    
    return 1
}

# -------------------------------------------------------
# Connection
# -------------------------------------------------------
ConnectProcess() {
	CheckPulse
	sleep 0.5
    systemctl stop bluetooth-icon-updater.service || true
	local mac="$1"
	local name=$(bluetoothctl info "$mac" | sed 's/\x1b\[[0-9;]*m//g' | sed -n 's/.*Alias: //p' | xargs)
	[ -z "$name" ] && name="$T_DEV_DEFAULT"
	local icon=$(bluetoothctl info "$mac" | grep "Icon:" | awk '{print $2}')
	
	(
    current_p=0
    smooth_bar() {
      local target=$1
      local msg=$2
      while [ $current_p -lt $target ]; do
        current_p=$((current_p + 1))
        echo "$current_p"; echo "XXX"; echo "$msg"; echo "XXX"
        sleep 0.04
      done
    }

    # --- Trust and Pairing ---
    smooth_bar 25 "$T_PROCESS ..."
    bluetoothctl trust "$mac" >/dev/null 2>&1
    if ! bluetoothctl info "$mac" | grep -q "Paired: yes"; then
        smooth_bar 50 "$T_PAIRING ..."
        bluetoothctl pair "$mac" >/dev/null 2>&1
    else
        smooth_bar 50 "$T_PROCESS ..."
    fi
    sleep 0.5

    # --- Connection ---
    smooth_bar 75 "$T_CONNECTING_TO $name ..."
    bluetoothctl connect "$mac" >/dev/null 2>&1
	sleep 0.5
    if [[ "$icon" == audio* ]]; then
		smooth_bar 100 "$T_FIXING_AUDIO"
	else
		smooth_bar 100 "$T_INIT"
	fi

    ) | dialog --backtitle "$T_BACKTITLE" --title "$T_CONN_TITLE" --gauge "" 8 50 0 > "$CURR_TTY"
	
	[[ "$icon" == audio* ]] && ApplyAudioFix
	
	if is_connected_stable "$mac"; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_SUCCESS" --msgbox "\n $name $T_CONNECTED\n" 7 50 > "$CURR_TTY"
	else
		dialog --backtitle "$T_BACKTITLE" --title "$T_FAILED" --msgbox "\n $T_FAIL_CONNECT $name.\n\n $T_FAIL_MSG" 12 50 > "$CURR_TTY"
	fi
    systemctl start bluetooth-icon-updater.service || true
}

# -------------------------------------------------------
# Disconnection
# -------------------------------------------------------
DisconnectProcess() {
	unset poptions
	while read -r line; do
	local mac=$(echo "$line" | awk '{print $2}')
	local name=$(echo "$line" | cut -d ' ' -f 3-)
      
		# --- Check if this device is connected ---
		if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
          poptions+=("$mac" "$name")
		fi
		
	done < <(bluetoothctl devices)

		# --- If nothing is connected ---
		if [ ${#poptions[@]} -eq 0 ]; then
			dialog --backtitle "$T_BACKTITLE" --title "$T_INFO" --msgbox "\n $T_NONE $T_CONNECTED" 7 35 > "$CURR_TTY"
			return
		fi
 
	pselection=$(dialog --backtitle "$T_BACKTITLE" --title "$T_M_DISCONNECT" --menu "$T_CHOOSE_DEV" 9 50 2 "${poptions[@]}" 2>&1 > "$CURR_TTY")
	[ $? -ne 0 ] && return

	local sel_name=$(bluetoothctl info "$pselection" | sed -n 's/.*Alias: //p' | xargs)
	[ -z "$sel_name" ] && sel_name="$T_DEV_DEFAULT"

	(
	echo "20"; echo "XXX"; echo "$T_PROCESS"; echo "XXX"
	timeout 5 bluetoothctl disconnect "$pselection" > /dev/null 2>&1
    
	echo "80"; echo "XXX"; echo "$T_PROCESS"; echo "XXX"
    
	ForceInternalAudio
	echo "100"
	) | dialog --backtitle "$T_BACKTITLE" --title "$T_CONN_TITLE" --gauge "\n $T_PROCESS" 8 50 0 > "$CURR_TTY"
    
	if bluetoothctl info "$pselection" | grep -q "Connected: no"; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_SUCCESS" --msgbox "\n $sel_name $T_DISCONNECTED" 7 40 > "$CURR_TTY"
	else
		dialog --backtitle "$T_BACKTITLE" --title "$T_FAILED" --msgbox "\n $T_FAIL_DISCONNECT $sel_name" 7 40 > "$CURR_TTY"
	fi
}

# -------------------------------------------------------
# List of Known Devices
# -------------------------------------------------------
ListKnownAndConnect() {
    (
	AutoEnableBT
	CheckPulse
	sleep 0.5
	) &
	local warmup_pid=$!
	
    unset koptions
    while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d ' ' -f 3-)
        koptions+=("$mac" "$name")
    done < <(bluetoothctl devices | while read -r _ mac name; do
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
        echo "Device $mac $name"
    fi
	done)
	
    if [ ${#koptions[@]} -eq 0 ]; then
       dialog --backtitle "$T_BACKTITLE" --title "$T_INFO" --msgbox "\n $T_NO_KNOWN" 7 33 > "$CURR_TTY"
       return
    fi
  
    kselection=$(dialog --backtitle "$T_BACKTITLE" --title "$T_KNOWN_DEV" --menu "$T_CONNECT_TO" 11 50 4 "${koptions[@]}" 2>&1 > "$CURR_TTY")
    local dialog_exit=$?
    wait $warmup_pid
    [ $dialog_exit -eq 0 ] && ConnectProcess "$kselection"
}

# -------------------------------------------------------
# Forget a Device
# -------------------------------------------------------
DeleteDevice() {
	(
	AutoEnableBT
	) &
	unset doptions
	while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d ' ' -f 3-)
        doptions+=("$mac" "$name")
	done < <(bluetoothctl devices | while read -r _ mac name; do
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
        echo "Device $mac $name"
    fi
	done)

	if [ ${#doptions[@]} -eq 0 ]; then
		dialog --backtitle "$T_BACKTITLE" --title "$T_INFO" --msgbox "\n $T_NOTHING_DEL" 7 25 > "$CURR_TTY"
		return
	fi

	dselection=$(dialog --backtitle "$T_BACKTITLE" --title "$T_DELETE_TITLE" --menu "$T_CHOOSE_DEL" 11 50 4 "${doptions[@]}" 2>&1 > "$CURR_TTY")
	if [ $? -eq 0 ]; then
		bluetoothctl remove "$dselection" > /dev/null 2>&1
		dialog --backtitle "$T_BACKTITLE" --title "$T_SUCCESS" --msgbox "\n $T_FORGOTTEN" 7 30 > "$CURR_TTY"
	fi
}

# -------------------------------------------------------
# Uninstaller GUI Helpers
# -------------------------------------------------------
ask_gui() {
    local TITLE="$1"
    local MSG="$2"
    dialog --backtitle "$T_BACKTITLE2" \
           --title "$TITLE" \
           --yesno "$MSG" 15 45 > "$CURR_TTY"
}

ask_s_gui() {
    local TITLE="$1"
    local MSG="$2"
    dialog --backtitle "$T_BACKTITLE2" \
           --title "$TITLE" \
           --yesno "$MSG" 8 45 > "$CURR_TTY"
}

info_gui() {
    local TITLE="$1"
    local MSG="$2"
    dialog --backtitle "$T_BACKTITLE2" \
           --title "$TITLE" \
           --msgbox "$MSG" 13 45 > "$CURR_TTY"
}

infobox_gui() {
    local TITLE="$1"
    local MSG="$2"
    dialog --backtitle "$T_BACKTITLE2" \
           --title "$TITLE" \
           --infobox "$MSG" 5 45 > "$CURR_TTY"
}

# -------------------------------------------------------
# Forget All Devices
# -------------------------------------------------------
ForgetAllDevices() {
    ask_s_gui "$T_FORGET_TITLE" "$T_FORGET_MSG"
    if [ $? -eq 0 ]; then
        infobox_gui "$T_FORGETTING_TITLE" "$T_FORGETTING_MSG"
        bluetoothctl devices | awk '{print $2}' | while read -r mac; do
            bluetoothctl remove "$mac" > /dev/null 2>&1
        done
        rm -rf "/var/lib/bluetooth/"*/
        sleep 0.5
        info_gui "$T_FORGOTTEN_TITLE" "$T_FORGOTTEN_MSG"
    fi
}

# -------------------------------------------------------
# Run Uninstaller
# -------------------------------------------------------
RunUninstall() {
	# -- Force audio back to internal speaker ---
	ForceInternalAudio
	sleep 0.1

    # --- Stop and Disable Services ---
    infobox_gui "$T_STEP1_TITLE" "$T_STEP1_MSG"

    for svc in bt-volume-monitor.service bt-sink-switch.service reset-alsa.service pulseaudio.service bluetooth.service; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            systemctl stop "$svc" 2>/dev/null
        fi
        if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            systemctl disable "$svc" 2>/dev/null
        fi
    done

    # --- Remove Installed Files ---
    infobox_gui "$T_STEP2_TITLE" "$T_STEP2_MSG"

    FILES_TO_REMOVE=(
        "/usr/local/bin/bt-volume-monitor.sh"
		"/usr/local/bin/bt-sink-switch.sh"
		"/usr/local/bin/reset-alsa.sh"
        "/etc/systemd/system/pulseaudio.service"
        "/etc/systemd/system/bt-volume-monitor.service"
		"/etc/systemd/system/bt-sink-switch.service"
		"/etc/systemd/system/reset-alsa.service"
		"/etc/udev/rules.d/99-input-event3.rules"
		"/etc/pulse/default.pa"
		"/etc/pulse/daemon.conf"
        "$INSTALLED_FLAG"
    )

    for f in "${FILES_TO_REMOVE[@]}"; do
        if [ -f "$f" ]; then
            rm -f "$f"
        fi
    done
	
	rm -rf /home/ark/.config/pulse/ 2>/dev/null || true
	rm -rf /run/user/${ARK_UID}/pulse/ 2>/dev/null || true
	cp /home/ark/.asoundrcbak /home/ark/.asoundrc 2>/dev/null || true
	sed -i '/autospawn = yes/d' /etc/pulse/client.conf 2>/dev/null || true
	sed -i '/PULSE_SERVER/d' /etc/environment 2>/dev/null || true
	sed -i '/XDG_RUNTIME_DIR/d' /etc/environment 2>/dev/null || true
	sudo udevadm control --reload-rules

    # --- Restore /etc/bluetooth/main.conf ---
    infobox_gui "$T_STEP3_TITLE" "$T_STEP3_MSG"

    if [ -f "/etc/bluetooth/main.conf" ]; then
        cat <<'EOF' > /etc/bluetooth/main.conf
[Policy]
AutoEnable=false
EOF
    fi

    # --- Restore /etc/pulse/system.pa ---
    infobox_gui "$T_STEP4_TITLE" "$T_STEP4_MSG"

    if [ -f "/etc/pulse/system.pa" ]; then
        cat <<'EOF' > /etc/pulse/system.pa
### Automatically restore the volume of streams and devices
load-module module-device-restore
load-module module-stream-restore
load-module module-card-restore

### Automatically augment property information from .desktop files
load-module module-augment-properties

### Should be after module-*-restore but before module-*-detect
load-module module-switch-on-port-available

### Load audio drivers statically
load-module module-udev-detect

### Use the static hardware detection module (for systems without udev support)
# load-module module-detect

### Automatically restore the default sink/source when changed by the user
load-module module-default-device-restore

### Automatically move streams to the default sink if the sink they are
### connected to dies, similar for sources
load-module module-rescue-streams

### Make sure we always have a sink around, even if it is a null sink.
load-module module-always-sink

### Honour intended role device property
load-module module-intended-roles

### Automatically suspend sinks/sources that become idle for too long
load-module module-suspend-on-idle

### Enable positioned event sounds
load-module module-position-event-sounds

### Cork music/video streams when a phone stream is active
load-module module-role-cork

### Modules to allow autoloading of filters (such as echo cancellation)
### on demand. module-filter-heuristics tries to determine what filters
### make sense, module-filter-apply does the heavy-lifting of loading
### temporary modules with appropriate arguments and doing the switch.
load-module module-filter-heuristics
load-module module-filter-apply
EOF
    fi

    # --- Restore bluetooth.service ---
    infobox_gui "$T_STEP5_TITLE" "$T_STEP5_MSG"

    BT_SERVICE="/lib/systemd/system/bluetooth.service"
    if [ -f "$BT_SERVICE" ]; then
        REAL_BT_PATH=$(find /usr -name bluetoothd -type f -executable | head -n 1)
        if [ -n "$REAL_BT_PATH" ]; then
            if grep -q "\-\-noplugin=sap" "$BT_SERVICE"; then
                sed -i "s|^ExecStart=.*--noplugin=sap.*|ExecStart=$REAL_BT_PATH -d|" "$BT_SERVICE"
            fi
        fi
    fi

    # --- Restore RetroArch Audio Driver ---
    infobox_gui "$T_STEP6_TITLE" "$T_STEP6_MSG"

    RA_CONFIGS=(
        "/home/ark/.config/retroarch/retroarch.cfg"
        "/home/ark/.config/retroarch32/retroarch.cfg"
    )

    for conf in "${RA_CONFIGS[@]}"; do
        if [ -f "$conf" ]; then
            if grep -q '^audio_driver = "sdl2"' "$conf"; then
                sed -i 's/^audio_driver = "sdl2"/audio_driver = "alsa"/' "$conf"
            fi
        fi
    done

    # --- Reload systemd  ---
    infobox_gui "$T_STEP7_TITLE" "$T_STEP7_MSG"
    systemctl daemon-reload
    sleep 0.5

    # --- OPTIONAL: Remove Packages ---
    ask_gui "$T_PKG_TITLE" "$T_PKG_MSG"

    if [ $? -eq 0 ]; then
    (
        current_p=0

        progress_while_running() {
			local pid=$1
			local target=$2
			local msg=$3
			echo "XXX"; echo "$msg"; echo "XXX"
			while kill -0 $pid 2>/dev/null; do
				if [ $current_p -lt $target ]; then
					current_p=$((current_p + 1))
					echo "$current_p"
				fi
				sleep 0.3
			done
			current_p=$target
			echo "$current_p"
}

        apt-get remove -y bluez pulseaudio pulseaudio-module-bluetooth bluez-tools libasound2-plugins dbus-x11 >/dev/null 2>&1 &
        progress_while_running $! 85 "$T_REMOVING_MSG"

        apt-get autoremove -y >/dev/null 2>&1 &
        progress_while_running $! 95 "$T_REMOVING_MSG"

        while [ $current_p -lt 100 ]; do
            current_p=$((current_p + 1))
            echo "$current_p"
            echo "XXX"; echo " $T_DONE_TITLE"; echo "XXX"
            sleep 0.05
        done

    ) | dialog --backtitle "$T_BACKTITLE2" --title "$T_REMOVING_TITLE" --gauge "\n$T_REMOVING_MSG" 7 55 0 > "$CURR_TTY"
	installed_packages_removed="$T_OPT_MSG"
	fi

    # --- Forget All Devices? ---
    ask_s_gui "$T_FORGET_TITLE" "$T_FORGET_MSG"
    if [ $? -eq 0 ]; then
        infobox_gui "$T_FORGETTING_TITLE" "$T_FORGETTING_MSG"
        rm -rf "/var/lib/bluetooth/"*/
        sleep 0.5
    fi

    # --- Summary ---
	info_gui "$T_DONE_TITLE" "${T_DONE_MSG//%PKG%/$installed_packages_removed}"
	
    # --- REBOOT ---
    ask_s_gui "$T_REBOOT_TITLE" "$T_REBOOT_MSG"
    if [ $? -eq 0 ]; then
        infobox_gui "$T_REBOOTING_TITLE" "$T_REBOOTING_MSG"
        sleep 0.5
        reboot
    else
        ExitMenu
    fi
}

# -------------------------------------------------------
# Uninstaller Menu
# -------------------------------------------------------
UninstallerMenu() {
    while true; do
        local CHOICE
        CHOICE=$(dialog --output-fd 1 \
            --backtitle "$T_BACKTITLE2" \
            --title "$T_MAIN_TITLE2" \
			--cancel-label "$T_BACK" \
            --menu "$T_MENU_MSG" 10 50 2 \
			1 "$T_RUN" \
            2 "$T_FORGET_MENU" \
			2>"$CURR_TTY")
			[ $? -ne 0 ] && return

        case $CHOICE in
            1) RunUninstall ;;
            2) ForgetAllDevices ;;
			*) return ;;
        esac
    done
}

# -------------------------------------------------------
# Main Menu
# -------------------------------------------------------
MainMenu() {
  CheckDeps
  EnsurePermissions
  
  while true; do
	# Keep gptokeyb alive
    if [[ -z $(pgrep -f gptokeyb) ]]; then
        StartGPTKeyb
    fi
  
    if GetPowerStatus; then
        BT_STAT="\Z2$T_ON\Zn"; DEV_NAME="\Z4$(GetConnectedName)\Zn"
		TOGGLE_LABEL="$T_DISABLE Bluetooth"
    else
        BT_STAT="\Z1$T_OFF\Zn"; DEV_NAME="$T_NONE"
		TOGGLE_LABEL="$T_ENABLE Bluetooth"
    fi
    
    mainselection=$(dialog --colors --backtitle "$T_BACKTITLE" --title "$T_MAIN_TITLE" --cancel-label "$T_EXIT" \
    --menu "$T_STATUS: $BT_STAT\n$T_CONN_TO: $DEV_NAME" 14 45 6 \
    1 "$TOGGLE_LABEL" \
    2 "$T_M_SCAN" \
    3 "$T_M_DISCONNECT" \
    4 "$T_M_KNOWN" \
    5 "$T_M_FORGET" \
	6 "$T_MAIN_TITLE2" 2>&1 > "$CURR_TTY")
        [ $? -ne 0 ] && ExitMenu
    case $mainselection in
        1) ToggleBT ;;
        2) ScanAndConnect ;;
        3) DisconnectProcess ;;
        4) ListKnownAndConnect ;;
        5) DeleteDevice ;;
		6) UninstallerMenu ;;
    esac
  done
}

# -------------------------------------------------------
# Gamepad Setup
# -------------------------------------------------------
export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
chmod 666 /dev/uinput
cp /opt/inttools/keys.gptk "$TMP_KEYS"
if grep -q '^b = backspace' "$TMP_KEYS"; then
    sed -i 's/^b = .*/b = esc/' "$TMP_KEYS"
    sed -i 's/^a = .*/a = enter/' "$TMP_KEYS"
fi
StartGPTKeyb

printf "\033[H\033[2J" > "$CURR_TTY"
dialog --clear
trap 'StopGPTKeyb; Cleanup; ExitMenu' EXIT


MainMenu