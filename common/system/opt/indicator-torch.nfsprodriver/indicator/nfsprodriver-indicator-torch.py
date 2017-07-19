import sys
import os
import json
import urllib.request
import subprocess
import shlex
import logging

from gi.repository import Gio
from gi.repository import GLib

BUS_NAME = 'com.nfsprodriver.indicator.torch'
BUS_OBJECT_PATH = '/com/nfsprodriver/indicator/torch'
BUS_OBJECT_PATH_PHONE = BUS_OBJECT_PATH + '/phone'

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


class TorchIndicator(object):
    ROOT_ACTION = 'root'
    ON_ACTION = 'on'
    OFF_ACTION = 'off'
    MAIN_SECTION = 0

    def __init__(self, bus):
        self.bus = bus
        self.action_group = Gio.SimpleActionGroup()
        self.menu = Gio.Menu()
        self.sub_menu = Gio.Menu()

        self.current_switch_icon = "torch-off"

    def get_text(self, condition):
        text = 'Indicator Torch'
        return text

    def get_icon(self, condition):
        icon = self.FOG
        return icon

    def on_action_activated(self, action, data):
        logger.debug('on_action_activated')
        # For some reason ubuntu-app-launch hangs without the version, so let cmake set it for us
        os.system('echo 255 > /sys/class/leds/led\:flash_torch/brightness')
        self.current_switch_icon = "torch-on"
        self.update_torch()
        


    def off_action_activated(self, action, data):
        logger.debug('off_action_activated')
        # For some reason ubuntu-app-launch hangs without the version, so let cmake set it for us
        os.system('echo 0 > /sys/class/leds/led\:flash_torch/brightness')
        self.current_switch_icon = "torch-off"
        self.update_torch()

    def _setup_actions(self):
        root_action = Gio.SimpleAction.new_stateful(self.ROOT_ACTION, None, self.root_state())
        self.action_group.insert(root_action)

        on_action = Gio.SimpleAction.new(self.ON_ACTION, None)
        on_action.connect('activate', self.on_action_activated)
        self.action_group.insert(on_action)

        off_action = Gio.SimpleAction.new(self.OFF_ACTION, None)
        off_action.connect('activate', self.off_action_activated)
        self.action_group.insert(off_action)

    def _create_section(self):
        section = Gio.Menu()

        on_menu_item = Gio.MenuItem.new('Torch on', 'indicator.{}'.format(self.ON_ACTION))
        section.append_item(on_menu_item)

        off_menu_item = Gio.MenuItem.new('Torch off', 'indicator.{}'.format(self.OFF_ACTION))
        section.append_item(off_menu_item)

        return section

    def _setup_menu(self):
        self.sub_menu.insert_section(self.MAIN_SECTION, 'Torch', self._create_section())

        root_menu_item = Gio.MenuItem.new('Torch', 'indicator.{}'.format(self.ROOT_ACTION))
        root_menu_item.set_attribute_value('x-canonical-type', GLib.Variant.new_string('com.canonical.indicator.root'))
        root_menu_item.set_submenu(self.sub_menu)
        self.menu.append_item(root_menu_item)

    def _update_menu(self):
        self.sub_menu.remove(self.MAIN_SECTION)
        self.sub_menu.insert_section(self.MAIN_SECTION, 'Torch', self._create_section())

    def update_torch(self):  # TODO see if the network status can be checked/watched
        logger.debug('Updated state to: {}'.format(self.current_icon()))
        # TODO figure out why this gives off a warning
        self.action_group.change_action_state(self.ROOT_ACTION, self.root_state())
        self._update_menu()

    def run(self):
        self._setup_actions()
        self._setup_menu()

        self.bus.export_action_group(BUS_OBJECT_PATH, self.action_group)
        self.menu_export = self.bus.export_menu_model(BUS_OBJECT_PATH_PHONE, self.menu)

        self.update_torch()

    def root_state(self):
        vardict = GLib.VariantDict.new()
        vardict.insert_value('visible', GLib.Variant.new_boolean(True))
        vardict.insert_value('title', GLib.Variant.new_string('Torch'))

        icon = Gio.ThemedIcon.new(self.current_icon())
        vardict.insert_value('icon', icon.serialize())

        return vardict.end()

    def current_icon(self):
        icon = self.current_switch_icon
        return icon


if __name__ == '__main__':
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    proxy = Gio.DBusProxy.new_sync(bus, 0, None, 'org.freedesktop.DBus', '/org/freedesktop/DBus', 'org.freedesktop.DBus', None)
    result = proxy.RequestName('(su)', BUS_NAME, 0x4)
    if result != 1:
        logger.critical('Error: Bus name is already taken')
        sys.exit(1)

    wi = TorchIndicator(bus)
    wi.run()

    logger.debug('Torch Indicator startup completed')
    GLib.MainLoop().run()
