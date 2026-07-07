<?php

namespace Database\Seeders;

use App\Models\Exercise;
use Illuminate\Database\Seeder;

class ExerciseSeeder extends Seeder
{
    public function run(): void
    {
        $exercises = [
            [
                'name' => 'Squat',
                'category' => 'Jambes',
                'muscles' => ['Quadriceps', 'Fessiers', 'Ischio-jambiers'],
                'difficulty' => 'Intermédiaire',
                'description' => 'Exercice polyarticulaire de base pour développer la force et la masse musculaire du bas du corps.',
                'instructions' => [
                    'Placez la barre sur le haut du dos, pieds largeur d\'épaules.',
                    'Descendez en pliant les genoux et les hanches, dos droit.',
                    'Descendez jusqu\'à ce que les cuisses soient parallèles au sol.',
                    'Remontez en poussant sur les talons.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=ultWZbUMPL8',
            ],
            [
                'name' => 'Développé couché',
                'category' => 'Poitrine',
                'muscles' => ['Pectoraux', 'Triceps', 'Épaules'],
                'difficulty' => 'Intermédiaire',
                'description' => 'Exercice de base pour développer la force et le volume des pectoraux.',
                'instructions' => [
                    'Allongez-vous sur le banc, pieds au sol.',
                    'Saisissez la barre un peu plus large que les épaules.',
                    'Descendez la barre jusqu\'à toucher la poitrine.',
                    'Poussez la barre vers le haut jusqu\'à extension complète.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
            ],
            [
                'name' => 'Tractions',
                'category' => 'Dos',
                'muscles' => ['Dorsaux', 'Biceps', 'Avant-bras'],
                'difficulty' => 'Avancé',
                'description' => 'Exercice au poids du corps pour développer le dos et les biceps.',
                'instructions' => [
                    'Suspendez-vous à la barre, paumes vers l\'avant.',
                    'Tirez le corps vers le haut jusqu\'à ce que le menton passe la barre.',
                    'Contrôlez la descente jusqu\'à extension complète des bras.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
            ],
            [
                'name' => 'Développé militaire',
                'category' => 'Épaules',
                'muscles' => ['Épaules', 'Triceps'],
                'difficulty' => 'Intermédiaire',
                'description' => 'Exercice de base pour développer la force et le volume des épaules.',
                'instructions' => [
                    'Debout, tenez la barre au niveau des épaules.',
                    'Poussez la barre au-dessus de la tête jusqu\'à extension complète.',
                    'Redescendez la barre au niveau des épaules avec contrôle.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
            ],
            [
                'name' => 'Curl biceps',
                'category' => 'Bras',
                'muscles' => ['Biceps'],
                'difficulty' => 'Débutant',
                'description' => 'Exercice d\'isolation pour développer les biceps.',
                'instructions' => [
                    'Debout, tenez un haltère dans chaque main, bras tendus.',
                    'Fléchissez les coudes en remontant les haltères vers les épaules.',
                    'Redescendez avec contrôle jusqu\'à extension complète.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
            ],
            [
                'name' => 'Dips',
                'category' => 'Triceps',
                'muscles' => ['Triceps', 'Pectoraux', 'Épaules'],
                'difficulty' => 'Intermédiaire',
                'description' => 'Exercice au poids du corps pour développer les triceps et les pectoraux.',
                'instructions' => [
                    'Placez-vous sur les barres parallèles, bras tendus.',
                    'Descendez en pliant les coudes jusqu\'à un angle de 90°.',
                    'Remontez en poussant jusqu\'à extension complète.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=2z8JmcrW-As',
            ],
            [
                'name' => 'Soulevé de terre',
                'category' => 'Dos',
                'muscles' => ['Dorsaux', 'Fessiers', 'Ischio-jambiers', 'Lombaires'],
                'difficulty' => 'Avancé',
                'description' => 'Exercice polyarticulaire majeur pour développer la force globale du corps.',
                'instructions' => [
                    'Placez-vous devant la barre, pieds largeur de hanches.',
                    'Saisissez la barre, dos droit, poitrine sortie.',
                    'Soulevez la barre en étendant les hanches et les genoux.',
                    'Redescendez la barre avec contrôle jusqu\'au sol.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=1ZXobu7JvvE',
            ],
            [
                'name' => 'Pompes',
                'category' => 'Poitrine',
                'muscles' => ['Pectoraux', 'Triceps', 'Épaules'],
                'difficulty' => 'Débutant',
                'description' => 'Exercice au poids du corps accessible pour développer la poitrine.',
                'instructions' => [
                    'Placez les mains au sol, largeur d\'épaules.',
                    'Descendez le corps en gardant le dos droit.',
                    'Remontez en poussant jusqu\'à extension complète des bras.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=IODxDxX7oi4',
            ],
            [
                'name' => 'Fentes',
                'category' => 'Jambes',
                'muscles' => ['Quadriceps', 'Fessiers', 'Ischio-jambiers'],
                'difficulty' => 'Débutant',
                'description' => 'Exercice unilatéral pour développer la force et l\'équilibre des jambes.',
                'instructions' => [
                    'Debout, faites un grand pas en avant.',
                    'Descendez jusqu\'à ce que les deux genoux forment un angle de 90°.',
                    'Remontez en poussant sur la jambe avant.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=QOVaHwm-Q6U',
            ],
            [
                'name' => 'Gainage',
                'category' => 'Abdominaux',
                'muscles' => ['Abdominaux', 'Lombaires'],
                'difficulty' => 'Débutant',
                'description' => 'Exercice isométrique pour renforcer la sangle abdominale et la stabilité du tronc.',
                'instructions' => [
                    'Placez les avant-bras au sol, coudes sous les épaules.',
                    'Alignez le corps de la tête aux talons.',
                    'Maintenez la position en contractant les abdominaux.',
                ],
                'youtube_url' => 'https://www.youtube.com/watch?v=ASdvN_XEl_c',
            ],
        ];

        foreach ($exercises as $exercise) {
            Exercise::updateOrCreate(['name' => $exercise['name']], $exercise);
        }
    }
}
