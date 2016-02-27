SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Create table `skins` if it doesn't exist
--

CREATE TABLE IF NOT EXISTS `skins` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Skin Id',
  `tags` longtext NOT NULL COMMENT 'Seperated by commas, no space',
  `url` text NOT NULL COMMENT 'URL of skin',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=79 ;

--
-- Insert a sample skin in the table `skins`
--

INSERT INTO `skins` (`id`, `tags`, `url`) VALUES
(1, 'agarpw,agar.pw,opensource', 'http://i.imgur.com/VqMKB7c.png');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
