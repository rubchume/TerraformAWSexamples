import configparser
from pathlib import Path


class TerraformVarsParser:
    DUMMY_SECTION = "dummy_section"

    def __init__(self):
        self.config = None

    def __getattr__(self, attr):
        return getattr(self.config, attr)

    def get(self, key):
        value = self.config.get(self.DUMMY_SECTION, key)
        if not isinstance(value, str):
            return value

        return value.strip('"')

    def read_file(self, file_path: str):
        configuration_file = Path(file_path)
        with configuration_file.open("r") as f:
            config_string = f"[{self.DUMMY_SECTION}]\n" + f.read()
            config = configparser.ConfigParser()
            config.read_string(config_string)

        self.config = config
