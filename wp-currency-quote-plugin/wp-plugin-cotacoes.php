<?php
/**
 * Plugin Name: Cotações Financeiras (Portfólio Sênior)
 * Plugin URI: https://github.com/fabricionarofe
 * Description: Plugin desenvolvido em POO para demonstrar uso de Hooks e consumo de API (Mock) no WordPress. Exibe um widget de cotações via Shortcode.
 * Version: 1.0.0
 * Author: Fabrício Nazareno Rodrigues Ferreira
 * Author URI: https://github.com/fabricionarofe
 * License: GPLv2 or later
 * Text Domain: wp-cotacoes
 */

// Se o arquivo for chamado diretamente, abortar.
if ( ! defined( 'WPINC' ) ) {
    die;
}

// Requerer a classe principal
require_once plugin_dir_path( __FILE__ ) . 'includes/class-cotacao-widget.php';

// Inicializar o plugin
function run_wp_cotacoes() {
    $plugin = new Cotacao_Widget();
    $plugin->init();
}

// Executar a inicialização
run_wp_cotacoes();
