<?php


namespace App\Controller;


use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class MainController extends AbstractController
{
    /**
     * @Route("/", name="app_entry_point")
     */
    public function __invoke()
    {
        return new Response(
            '<html lang="en"><body>You made it!</body></html>'
        );
    }
}