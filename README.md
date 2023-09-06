# A Docker Image for WinterCMS running over Apache

## Description
This Docker image is designed to run WinterCMS, a content management system, within a Docker environment. It comes pre-configured with the necessary dependencies to smoothly run WinterCMS.

## Usage
To use this image, you can run the following command:

```bash
docker run -d --name my-container -p 80:80 -v /local/path/to/your/application:/var/www/html pmietlicki/wintercms:latest
```

### Parameters

- `-d`: Run the container in detached mode.
- `--name my-container`: Specify a name for your container.
- `-p 80:80`: Map port 80 of the container to port 80 on the host to access WinterCMS via a web browser.
- `-v /local/path/to/your/application:/var/www/html`: Mount a local volume into the container to store your application files.

## Customization
You can customize this image by modifying WinterCMS configuration files or by adding custom plugins and themes. You can do this by using a custom Dockerfile based on this base image.

### WinterCMS Environment Variables

When running WinterCMS in a Docker container or any environment, you can configure its behavior using environment variables (ENV). Here is a list of commonly used ENV variables and their descriptions:

- `APP_DEBUG`: Controls whether debug mode is enabled (true/false).
- `APP_KEY`: The application key used for encryption.
- `APP_URL`: The URL of your WinterCMS application.
- `CACHE_DRIVER`: The caching driver to use (e.g., `file`, `database`, `redis`).
- `DB_CONNECTION`: The database connection type (e.g., `mysql`, `pgsql`, `sqlite`).
- `DB_DATABASE`: The name of the database.
- `DB_HOST`: The hostname of the database server.
- `DB_PASSWORD`: The database password.
- `DB_USERNAME`: The database username.
- `REDIS_HOST`: The hostname of the Redis server.
- `REDIS_PORT`: The port number of the Redis server.
- `LINK_POLICY`: The link policy for managing links (e.g., `secure`, `detect`, `force`).
- `QUEUE_CONNECTION`: The queue connection type (e.g., `sync`, `database`, `redis`).

You can set these environment variables in your Docker container or environment to configure WinterCMS according to your requirements. Be sure to consult WinterCMS documentation for more details on each of these variables and their usage.

If no .env file is found in the mounted volume at /var/www/html, the image will automatically perform a fresh installation and configuration of WinterCMS with default settings. You can then customize the .env file to meet your specific requirements. Alternatively, you can use global environment variables within your Docker container, but if you want to avoid a fresh installation, it's important to retain the .env file.

Example using env variables :
```bash
docker run -d --name my-container -p 80:80 -v /local/path/to/your/application:/var/www/html \
-e APP_DEBUG=true \
-e APP_KEY=your-app-key \
-e DB_CONNECTION=mysql \
-e DB_DATABASE=mydatabase \
-e DB_HOST=db.example.com \
-e DB_USERNAME=dbuser \
-e DB_PASSWORD=dbpassword \
pmietlicki/wintercms:latest
```

## Available Versions
- `latest`: The most recent version of WinterCMS.
- `v1.2.3`: WinterCMS version 1.2.3

## WinterCMS Documentation
For detailed information on using WinterCMS, refer to the [official WinterCMS documentation](https://wintercms.com/docs).

## License
This project is licensed under the MIT License.

---

For more information about WinterCMS, visit the official website: [https://wintercms.com](https://wintercms.com)
